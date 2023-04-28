import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

import 'package:sentry/sentry.dart';

enum LauncherState {
  canDownload,
  canUpdate,
  canInstall,
  canRun,
  waiting,
  downloading,
  installing,
  uninstalling,
  updating,
  preparingUpdate,
  running,
  connecting
}

class Launcher {
  //PATHS
  String root = path.current;

  String getArchivePath() => path.join(root, "download.zip");

  Future<bool> archiveExists() => new File(getArchivePath()).exists();

  String getExtractDir() => path.join(root, "game");

  String getGameDir() => getExtractDir() + "";

  //EXECUTABLES
  String? macExecutablePath = null;
  String? windowsExecutablePath = null;

  bool canRun() =>
      (Platform.isMacOS && macExecutablePath != null) ||
      (Platform.isWindows && windowsExecutablePath != null);

  //VERSION CONTROL
  Version? localAppVersion = null;
  Version? remoteAppVersion = null;

  bool canUpgrade() =>
      remoteAppVersion != null &&
      (localAppVersion == null || localAppVersion! < remoteAppVersion!);

  String getAppVersionPath() => path.join(root, ".appVersion");

  String getLauncherVersionPath() => path.join(root, ".launcherVersion");

  //STATE
  LauncherState _currentState = LauncherState.waiting;

  void _setState(LauncherState s) {
    _currentState = s;
    stateListener(s, null);
  }

  void _setProgress(DownloadInfo p) => stateListener(_currentState, p);

  LauncherState getState() => _currentState;
  Function(LauncherState, DownloadInfo?) stateListener = (s, d) => {};

  //CONSTRUCTOR
  Launcher._(Function(LauncherState, DownloadInfo?) listener) {
    this.stateListener = listener;
  }

  //async INIT
  static Future<Launcher> create(
      Function(LauncherState, DownloadInfo?) listener) async {
    var l = new Launcher._(listener);
    //paths

    l.root = Platform.isWindows
        ? Directory.current.parent.path
        : (await getApplicationSupportDirectory()).path;

    Directory(l.getExtractDir()).createSync();
    l.updateExecutablePaths();

    //version control
    var f = new File(l.getAppVersionPath());
    if (!f.existsSync()) f.createSync();
    l.localAppVersion = await l.getLocalAppVersion();
    l.remoteAppVersion = await l.getRemoteAppVersion();
    l.updateState();

    if(Platform.isWindows){
      Process.run("../Update.exe", [
        "--update",
        "https://bridgestars-static-host.s3.eu-north-1.amazonaws.com/launcher/win"
      ]).then((x) {
        print(x.stdout);
        print(x.stderr);
      }).catchError((e) {
        print(e);
        Sentry.captureException(
            new Exception("Could not run update process: " + e.toString()),
            stackTrace: StackTrace.current);
      });
    }
    return l;
  }

  Future refreshAppVersion() async {
    remoteAppVersion = await getRemoteAppVersion();
    localAppVersion = await getLocalAppVersion();
    return;
  }

  Future handleBtnPress() async {
    switch (_currentState) {
      case LauncherState.canDownload:
        _setState(LauncherState.downloading);
        await download(_setProgress);
        _setState(LauncherState.installing);
        await install();
        await setLocalAppVersion(remoteAppVersion!);
        updateState();
        break;

      case LauncherState.canUpdate:
        _setState(LauncherState.preparingUpdate);
        await uninstall();
        _setState(LauncherState.updating);
        await download(_setProgress);
        await install();
        await setLocalAppVersion(remoteAppVersion!);
        updateState();
        break;

      case LauncherState.canRun:
        runApp();
        return LauncherState.running;

      case LauncherState.canInstall:
        _setState(LauncherState.installing);
        await install();
        await setLocalAppVersion(remoteAppVersion!);
        updateState();
        break;
      case LauncherState.waiting:
      case LauncherState.downloading:
      case LauncherState.installing:
      case LauncherState.uninstalling:
      case LauncherState.updating:
      case LauncherState.running:
      case LauncherState.connecting:
      case LauncherState.preparingUpdate:
        //Dont care
        //maybe open alert
        break;
    }
  }

  Future<LauncherState> updateState() async {
    if (canUpgrade() && localAppVersion != null)
      _setState(LauncherState.canUpdate);
    else if (await updateExecutablePaths())
      _setState(LauncherState.canRun);
    else if (await archiveExists()) {
      _setState(LauncherState.canInstall);
    } else
      _setState(LauncherState.canDownload);
    return _currentState;
  }

  Future<bool> updateExecutablePaths() async {
    if (Platform.isMacOS)
      macExecutablePath = await _findMacExecutable(getExtractDir());
    if (Platform.isWindows)
      windowsExecutablePath = await _findWindowsExecutable(getExtractDir());
    print(macExecutablePath);
    return canRun();
  }

  //#region Run

  /// Runs the executable, figures out operating system.
  Future runApp() async {
    if (canRun()) {
      if (Platform.isMacOS) {
        _rewriteMacExecutablePermission(macExecutablePath!);
        _runMacExecutable(macExecutablePath!);
        Sentry.captureEvent(new SentryEvent(
            message: SentryMessage("Start Game"),
            level: SentryLevel.info,
            breadcrumbs: null));
      } else if (Platform.isWindows) {
        _runWindowsExecutable(windowsExecutablePath!);
        Sentry.captureEvent(new SentryEvent(
            message: SentryMessage("Start Game"),
            level: SentryLevel.info,
            breadcrumbs: null));
      } else
        throw new Exception(
            "Platform not supported: " + Platform.operatingSystem);
    } else
      throw new Exception("Executable not found");
  }

  void _runWindowsExecutable(String path) {
    print("RUNNING");
    print(path);
    var dirPath = path.split('\\');
    var exeName = dirPath.removeLast();
    var result = Process.runSync(
        'cd', [dirPath.join('\\'), '&qw&', 'start', exeName],
        runInShell: true);
    print(result.stdout);
    print(result.stderr);
  }

  void _rewriteMacExecutablePermission(String p) {
    //Write permission to execute app
    // var innerExecutable =
    //     Directory(path.join(p, "Contents", "MacOS")).listSync().first.path;
    var result =
        Process.runSync("xattr", ["-d", "-r", "com.apple.quarantine", p]);
    // var result = Process.runSync('chmod', ["+x", innerExecutable]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }

  ///runPath should point to an app executable
  void _runMacExecutable(String path) {
    print("RUNNING: " + path);
    //Run
    var result = Process.runSync('open', [path]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }

  Future<String?> _findMacExecutable(String folderPath) async {
    var dir = Directory(folderPath).listSync(recursive: true).toList();
    var app = dir
        .map((e) => e.path)
        .firstWhere((element) => element.endsWith('.app'), orElse: () => '');
    return app.isEmpty ? null : app;
  }

  Future<String?> _findWindowsExecutable(String folderPath) async {
    var dir = Directory(folderPath).listSync(recursive: true).toList();
    print("Finding windows executable in: " + folderPath);
    // dir.forEach((element) {
    //   print(element);
    // });
    var exe = dir
        .map((e) => e.path)
        .firstWhere((e) => e.endsWith('Bridgestars.exe'), orElse: () => '');
    return exe.isEmpty ? null : exe;
  }

  //#endregion

  //region upgrade

  Future _upgradeAppVersion(Version newVersion, Function()) async {
    await uninstall();
  }

//endregion

//#region install
  Future install() async {
    //TODO unzip in background thread
    //start new thread
    var t = Sentry.startTransaction(
        "Install",
        "from " +
            localAppVersion.toString() +
            " to " +
            remoteAppVersion.toString());
    await _unzip(getArchivePath(), getExtractDir());
    await updateExecutablePaths();
    var f = new File(getArchivePath());
    if (f.existsSync()) f.deleteSync();
    t.finish();
    return;
  }

  ///Should work on both mac and windows
  Future _unzip(String zipPath, String unzipPath) async {
    print("EXTRACTING");
    // Use an InputFileStream to access the zip file without storing it in memory.

    try {
      var start = DateTime.now();
      if (Platform.isWindows) {
        var s = DateTime.now();
        var time = () {
          print(DateTime.now().difference(s));
          start = DateTime.now();
        };

        await Isolate.run(() {
          var bytes = File(zipPath).readAsBytesSync();
          var archive = ZipDecoder().decodeBytes(bytes);
          time();
          for (var file in archive) {
            var fileName = '$unzipPath/${file.name}';
            if (file.isFile) {
              //start timer
              //_tempImages.add(outFile.path);
              if (fileName.contains('__MACOSX')) continue;
              var st = DateTime.now();
              var outFile = File(fileName);
              //print("Extracting: " + fileName);
              outFile.createSync(recursive: true);
              outFile.writeAsBytesSync(file.content);
              //print("Time: " + DateTime.now().difference(st).toString());
            }
          }
        });
        time();
      } else if (Platform.isMacOS) {
        // print([zipPath, "-d", path.join(unzipPath, "")]);
        var result = await Process.run(
            'unzip', ["-o", zipPath, "-d", path.join(unzipPath, "")]);
        // print(result.stdout);
        if (result.stderr.toString().isNotEmpty) {
          throw new Exception(result.stderr.toString());
        }
      } else
        throw new Exception(
            "Platform not supported: " + Platform.operatingSystem);

      var end = DateTime.now();
      var diff = end.difference(start).inMilliseconds;
      print("Time to extract: " + diff.toString() + "ms");
    } catch (e, stacktrace) {
      print(e);
      throw new Exception("Download was corrupted, please try again");
    }

    //await _removeArchive();
    return;
  }
//#endregion install

//region uninstall

  Future canUninstall() async =>
      new File(getAppVersionPath()).existsSync() ||
      new Directory(getGameDir()).listSync(recursive: true).length != 0 ||
      await archiveExists();

  Future uninstall() async {
    await _removeArchive();
    await _removeGameDir();
    await _removeVersionFile();
    localAppVersion = null;
    remoteAppVersion = null;
  }

  Future _removeVersionFile() async {
    var f = new File(getAppVersionPath());
    if (f.existsSync()) f.deleteSync();
  }

  Future _removeGameDir() async {
    if (new Directory(getGameDir()).existsSync())
      new Directory(getGameDir())
          .listSync()
          .forEach((file) => file.deleteSync(recursive: true));
  }

  Future _removeArchive() async {
    if (await archiveExists()) new File(getArchivePath()).deleteSync();
  }

//endregion

//#region download
  Future download(void Function(DownloadInfo) callback) async {
    if (remoteAppVersion == null)
      throw new Exception("Current version not set");
    var transaction = Sentry.startTransaction(
        'Download',
        "From " +
            localAppVersion.toString() +
            " to " +
            remoteAppVersion.toString());
    await _downloadFile(remoteAppVersion!.getUrl(), getArchivePath(), callback);
    transaction.finish();
  }

  Future _downloadFile(
      String uri, String savePath, void Function(DownloadInfo) callback) async {
    print("DOWNLOADING");

    int lastRcv = 0;
    var lastTime = new DateTime.now();
    Duration diff() => new DateTime.now().difference(lastTime);
    double calcSpeed(rcv) => (rcv - lastRcv) / (diff().inMicroseconds);
    double percentDone = 0;
    double speedMBs = 0;
    double secondsLeft = 0;
    void calcProgress(int rcv, int total) {
      percentDone = ((rcv / total) * 100);
      speedMBs = calcSpeed(rcv);
      secondsLeft = ((total - rcv) / speedMBs) / 1e6;
    }

    await Dio().download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        //print(
        //    'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
        calcProgress(rcv, total);
        callback(new DownloadInfo(
            percentDone, speedMBs, secondsLeft)); //.toStringAsFixed(0);
      },
      deleteOnError: true,
    );
    return;
  }
//#endregion download

//#region version control

  Version? _getLatestVersionFromFirestoreDoc(Map<String, dynamic> doc) {
    var xs = doc['fields']['versions']['arrayValue']['values'] as List<dynamic>;
    var versions = xs.map((e) {
      var fields = e['mapValue']['fields'];
      var url = fields['url']['stringValue'];
      var info = fields['info']['stringValue'];
      var nbr = fields['nbr']['stringValue'];
      return Version.parse(nbr, url, info);
    });
    Version? current =
        localAppVersion != null ? localAppVersion : versions.first;
    versions.forEach((v) =>
        {if (current == null || (v != null && v > current!)) current = v});
    return current;
  }

  Future<Version> getRemoteAppVersion() async {
    var s = _currentState;
    _setState(LauncherState.connecting);
    print("Getting remote app version");
    Version? v;
    Map<String, dynamic> data;
    try {
      var docName = Platform.isWindows ? "game-windows" : "game-mac";
      var url = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/bridge-fcee8/databases/(default)/documents/versions/' +
              docName);
      print(url);
      var res = await http.get(url);

      print("Fetched remote app version");
      data = json.decode(res.body) as Map<String, dynamic>;
      print("Parsed remote app version");
    } catch (e) {
      throw new Exception(
        "Could not connect, please check your internet connection",
      );
    }
    try {
      v = _getLatestVersionFromFirestoreDoc(data);
      if (v != null) {
        _setState(s);
        print(v);
        return v;
      }
      throw new Exception();
    } catch (e) {
      throw new Exception("Could not parse remote app version");
    }
  }

  Future<Version?> getLocalAppVersion() async {
    var f = new File(getAppVersionPath());
    if (!f.existsSync()) return null;
    var lines = new File(getAppVersionPath()).readAsLinesSync();
    if (lines.length != 3) return null;
    return Version.parse(lines[0], lines[1], lines[2]);
  }

  Future setLocalAppVersion(Version v) async {
    localAppVersion = v;
    await File(getAppVersionPath()).writeAsString(v.getNbr() +
        "\n" +
        v.getUrl() +
        "\n" +
        v.getInfo().replaceAll('\n', ';'));
  }

//#endregion

  Future waitForGameClose() async {
    var checkForUpdates = () async {
      await refreshAppVersion();
      await updateState();
    };
    if (Platform.isMacOS) {
      var r = Process.runSync('ps', ['-e']);
      print(r.stderr.toString());

      if (!r.stdout.toString().contains(getGameDir())) {
        print(
            "GAME IS NOT RUNNING ANYMORE: Opening and checking for new updates");
        checkForUpdates();
        return;
      }
    } else if (Platform.isWindows) {
      var r = Process.runSync(
          'tasklist', ['/svc', '|', 'findstr', 'Bridgestars.exe'],
          runInShell: true);
      print(r.stderr.toString());
      print(r.stdout.toString());
      if (!r.stdout.toString().contains("Bridgestars.exe")) {
        print(
            "GAME IS NOT RUNNING ANYMORE: Opening and checking for new updates");

        checkForUpdates();
        return;
      }
    }
    print("GAME IS RUNNING");
    await Future.delayed(Duration(milliseconds: 500))
        .then((e) => waitForGameClose());
  }
}

//#region data classes

class DownloadInfo {
  DownloadInfo(this.percentDone, this.speedMBs, this.secondsLeft);

  double percentDone;
  double speedMBs;
  double secondsLeft;

  @override
  String toString() {
    return '${percentDone.toStringAsFixed(1)}%  ${speedMBs.toStringAsFixed(1)} MB/s  ${secondsLeft.toStringAsFixed(0)} s';
  }
}

bool isNumeric(String s) => int.tryParse(s) != null;

class Version extends Comparable {
  var _nbrs = [0, 0, 0];
  var _url = '';
  var _info = "";

  String getNbr() => _nbrs.join('.');

  String getUrl() => _url;

  String getInfo() => _info;

  String toString() => "Version(" + getNbr() + ", " + _url + ", " + _info + ")";
  String getDisplayValue() {
    var a = "Alpha ";
    if (_nbrs[0] != 0)
      a = "Release ";
    else if (_nbrs[1] != 0) a = "Beta ";
    return a + getNbr();
  }

  Version._(List<int> nbrs, String url, String info) {
    _nbrs = nbrs;
    _url = url;
    _info = info.replaceAll(';', '\n');
  }

  static Version? parse(String s, String url, String info) {
    var split = s.split('.');
    if (split.length == 3 && split.every(isNumeric)) {
      return new Version._(split.map((e) => int.parse(e)).toList(), url, info);
    }
    return null;
  }

  bool operator >(Version other) => compareTo(other) == 1;

  bool operator <(Version other) => compareTo(other) == -1;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == Version && compareTo(other) == 0;

  @override
  int compareTo(other) {
    for (var i = 0; i < 3; i++) {
      if (_nbrs[i] > other._nbrs[i])
        return 1;
      else if (_nbrs[i] < other._nbrs[i]) return -1;
    }
    return 0;
  }
}

//#endregion
