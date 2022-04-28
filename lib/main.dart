import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bridgestars_launcher/data/data.dart';
import 'package:bridgestars_launcher/models/current_track_model.dart';
import 'package:bridgestars_launcher/screens/playlist_screen.dart';
import 'package:bridgestars_launcher/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

enum Phase {
  begin,
  downloading,
  installing,
  done,
  error
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setMinWindowSize(const Size(600, 800));
    //http.get(Uri.parse("https://cdn-124.anonfiles.com/L1ceW1a2y8/075596e0-1651126397/Bridgestars%20For%20MacOSX%20-%20Alpha%20v1.0.2.app.zip")).then((response) {
    //  new File("BridgestarsAlpha.zip").writeAsBytes(response.bodyBytes);
    //}).catchError(onError =);

  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrentTrackModel(),
      child: MyDownloadApp(),
    ),
  );
}

class MyDownloadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Download',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'File Download With Progress'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title="asd"}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  Phase phase = Phase.begin;
  String progress = '0';

  String uri =
      'https://onedrive.live.com/download?cid=3F5E79BDE61E7EA5&resid=3F5E79BDE61E7EA5%2128381&authkey=ALH_V94FQ3PnTjY';

  String filename = 'test.zip'; // file name that you desire to keep


  // downloading logic is handled by this method

  Future downloadAndRun(uri) async {
    String folderPath = Directory.current.path + "/app_dir";
    String downloadPath = folderPath+"/"+filename;
    String unzipPath = folderPath+"/game";
    String runPath = unzipPath+"/Bridgestars For MacOSX - Alpha v1.0.2.app";

    print(runPath);
    //await run(runPath);
    print(await new File(runPath).exists());
    if(await new File(runPath).exists()){
      phase = Phase.done;
      await run(runPath);
    }
    else if(await new File(downloadPath).exists())
    {
      phase = Phase.installing;
      await unzip(downloadPath, unzipPath);
      phase = Phase.done;
      await run(runPath);
    }
    else{
      phase = Phase.downloading;
      await downloadFile(uri, downloadPath);
      phase = Phase.installing;
      await unzip(downloadPath, unzipPath);
      phase = Phase.done;
      await run(runPath);
    }
  }


  Future<void> downloadFile(uri, savePath) async {
    print("DOWNLOADING");
    setState(() {
      phase = Phase.downloading;
    });

    Dio dio = Dio();

    dio.download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        //print(
        //    'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
        setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
        });
        if (progress == '100') {
          setState(() {
            phase = Phase.installing;
          });
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    )
    .catchError((e) => print(e.toString()));
  }

  Future unzip(String zipPath, String unzipPath) async {
    print("EXTRACTING");
    // Use an InputFileStream to access the zip file without storing it in memory.

      var bytes = new File(zipPath).readAsBytesSync();
      var archive = ZipDecoder().decodeBytes(bytes);
      for (var file in archive) {
        var fileName = '$unzipPath/${file.name}';
        if (file.isFile) {
          var outFile = File(fileName);
          if(outFile.path.contains("MacOS/Bridgestars")){
            print('File:: ' + outFile.path);
          }
          //_tempImages.add(outFile.path);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
  }

  Future run(String runPath) async {
    print("RUNNING");
    await Process.run('chmod', ["+x",runPath + "/Contents/MacOS/Bridgestars"]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
    await Process.run('open', [runPath]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
  }

  //gets the applicationDirectory and path for the to-be downloaded file

  // which will be used to save the file to that path in the downloadFile method


  String getPhaseDescription() {
    switch (phase) {
      case Phase.begin:
        return "Download";
      case Phase.downloading:
        return "Downloading";
      case Phase.installing:
        return "Installing";
      case Phase.done:
        return "Start";
      case Phase.error:
        return "An error occurred";
    }
  }
    @override
    Widget build(BuildContext context) {
      print('build running');

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$progress%'),
                Text(getPhaseDescription()),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () async {
              await downloadAndRun(uri);
              //downloadFile(uri, filename);
            }),
      );
    }
  }


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spotify UI',
      debugShowCheckedModeBanner: false,
      theme : defaultTheme,
      home: Shell(),
    );
  }
}

class Shell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width > 800) SideMenu(),
                const Expanded(
                  child: PlaylistScreen(playlist: lofihiphopPlaylist),
                ),
              ],
            ),
          ),
          CurrentTrack(),
        ],
      ),
    );
  }
}

ThemeData defaultTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
  scaffoldBackgroundColor: const Color(0xFF121212),
  backgroundColor: const Color(0xFF121212),
  primaryColor: Colors.black,
/*  colorScheme: new ColorScheme(brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface),*/
  accentColor: const Color(0xFFF74040),
  iconTheme: const IconThemeData().copyWith(color: Colors.white),
  fontFamily: 'Montserrat',
  textTheme: TextTheme(
    headline2: const TextStyle(
      color: Colors.white,
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      fontSize: 12.0,
      color: Colors.grey[300],
      fontWeight: FontWeight.w500,
      letterSpacing: 2.0,
    ),
    bodyText1: TextStyle(
      color: Colors.grey[300],
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    bodyText2: TextStyle(
      color: Colors.grey[300],
      letterSpacing: 1.0,
    ),
  ),
);
