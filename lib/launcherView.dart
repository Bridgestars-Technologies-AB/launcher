import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bridgestars_launcher/main.dart';
import 'package:bridgestars_launcher/settingsPanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'launcher.dart';
import 'videoView.dart';
import 'dialogs.dart';

class LauncherView extends StatefulWidget {
  final GlobalKey<VideoViewState> videoViewKey;

  LauncherView({Key? key, required this.showUI, required this.videoViewKey})
      : super(key: key);

  final bool showUI;

  @override
  _LauncherViewState createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> with WindowListener {
  DownloadInfo? progress;
  Launcher? launcher;
  LauncherState launcherState = LauncherState.waiting;
  String launcherStateString =
      getLauncherStateString(LauncherState.waiting, null);
  bool showBtn = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    try {
      launcher = await Launcher.create(setLauncherState);
      print('Game Dir: "' + launcher!.getGameDir().toString() + '"');

      //TODO REMOVE THIS
      if (Platform.isWindows) {
        // var res = await Process.run(
        //     "cd",
        //     [
        //       launcher!.getGameDir(),
        //       "&&"
        //           "start"
        //           "."
        //     ],
        //     runInShell: true);
        // print("err" + res.stderr.toString());
        // print("res" + res.stdout.toString());
      } else {
        //   await Process.run('open', ['-a', 'finder', launcher!.getGameDir()]);
        //   await Process.run(
        //       'open', ['-a', 'TextEdit', launcher!.root + "/.appVersion"]);
      }
      //
    } catch (e) {
      await showErrorRetryDialog(
          widget: widget, message: getExceptionMessage(e));
      _init();
    }
  }

  void _handleBtnPress() async {
    try {
      if (launcherState == LauncherState.canRun) {
        var a = await launcher?.updateExecutablePaths();
        if (a == false) {
          launcher?.updateState();
          await showCustomDialog(
              message: "It seems like your game files are corrupted",
              widget: widget,
              positiveButtonTitle: "Download missing files");
          _handleBtnPress();
          return;
        } else {
          await widget.videoViewKey.currentState?.playOutroAndHide();
          await launcher?.handleBtnPress();
          await Future.delayed(Duration(seconds: 1));
          await launcher?.waitForGameClose();
          await widget.videoViewKey.currentState?.showWithBackground();
        }
      } else
        launcher?.handleBtnPress();
    } catch (e) {
      await showErrorRetryDialog(
          message: getExceptionMessage(e), widget: widget);
      _handleBtnPress();
    }
  }

  String getExceptionMessage(e) =>
      e.toString().substring(e.toString().indexOf(':') + 1);

/*  void OpenErrorModal(String message, List<String> btnTexts,
      List<Function()> btnActions) async {
    if (widget.showUI) {
      var m = message.substring(message.indexOf(':') + 1);
      //TODO add report btn
      showAlertDialog("Ops, Something went wrong", m,
          btnTexts.map((s) => Text(s)).toList(), btnActions);
    } else
      Future.delayed(Duration(milliseconds: 50))
          .then((v) => OpenErrorModal(message, btnTexts, btnActions));
  }*/

  void setLauncherState(LauncherState s, DownloadInfo? p) => setState(() {
        launcherState = s;
        launcherStateString = getLauncherStateString(s, launcher);
        progress = p;
        showBtn = [
          LauncherState.canRun,
          LauncherState.canDownload,
          LauncherState.canUpdate
        ].contains(s);
      });

  bool settingsPanel = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context)
        .size
        .width; // * MediaQuery.of(context).devicePixelRatio;
    var height = MediaQuery.of(context)
        .size
        .height; // * MediaQuery.of(context).devicePixelRatio;
    return Stack(children: [
      if (launcher?.localAppVersion != null)
        Padding(
            padding: EdgeInsets.all(width / 100),
            child: Align(
              child: Text(
                launcher!.localAppVersion!.getDisplayValue(),
                style: TextStyle(color: Colors.white60, fontSize: width / 80),
              ),
              alignment: Alignment.bottomLeft,
            )),
      Padding(
          padding: EdgeInsets.all(width / 70),
          child: Align(
            child: IconButton(
              onPressed: () {
                setState(() {
                  settingsPanel = !settingsPanel;
                });
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white70,
              ),
              tooltip: "Settings",
              //mouseCursor: SystemMouseCursors.click,
              iconSize: height / 18,
            ),
            alignment:
                Platform.isWindows ? Alignment.topLeft : Alignment.topRight,
          )),
      if (widget.showUI)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          showBtn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: height * 0.5),
                    Container(
                        constraints: BoxConstraints(
                            minHeight: height / 11,
                            maxHeight: height / 11,
                            minWidth: width / 7),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(
                                //borderRadius: BorderRadius.circular(height/30),
                                side: BorderSide(color: Colors.red)),
                            primary: Color.fromARGB(255, 255, 100, 100),
                            //shadowColor: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          onPressed: _handleBtnPress,
                          child: Text(launcherStateString,
                              style: TextStyle(
                                  fontSize: width / 35, color: Colors.white)),
                        )),
                    Container(height: height / 100),
                    // TextButton(

                    if (launcherState == LauncherState.canUpdate)
                      TextButton(
                          onPressed: () async {
                            // var title = isUpdate ? "Update Notes" : "General Information";
                            // var m = isUpdate ? launcher?.remoteAppVersion?.getInfo()
                            // var m = launcher?.localAppVersion?.getInfo() ?? "www.bridgestars.se";
                            showAppInfoDialog(launcher?.remoteAppVersion, null);
                          },
                          child: Text("Update Notes",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white70,
                                  fontSize: width / 60)))
                  ],
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(height: height * 0.5),
                  Container(
                    width: width / 20,
                    height: width / 20,
                    alignment: Alignment.center,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                      colors: const [Colors.white70],
                    ),
                  ),
                  Container(height: height / 30),
                  Text(launcherStateString,
                      style: TextStyle(
                          fontSize: width / 60, color: Colors.white70)),
                  Container(height: height / 30),
                  if ((launcherState == LauncherState.downloading ||
                          launcherState == LauncherState.updating) &&
                      progress != null)
                    SizedBox(
                        width: width / 4,
                        child: Row(
                            //return '${percentDone.toStringAsFixed(1)}%  ${speedMBs.toStringAsFixed(1)} MB/s  ${secondsLeft.toStringAsFixed(0)} s';
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  progress!.percentDone.toStringAsFixed(1) +
                                      "%",
                                  style: TextStyle(
                                      fontSize: width / 60,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: Colors.white70)),
                              Text(
                                  progress!.speedMBs.toStringAsFixed(1) +
                                      " MB/s",
                                  style: TextStyle(
                                      fontSize: width / 60,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: Colors.white70)),
                              Text(
                                  progress!.secondsLeft.toStringAsFixed(0) +
                                      " s",
                                  style: TextStyle(
                                      fontSize: width / 60,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: Colors.white70)),
                            ])) //progress
                ])
        ]),
      if (settingsPanel)
        drawSettingsPanel(
            context,
            launcher,
            () => setState(() {
                  settingsPanel = !settingsPanel;
                })),
    ]);
  }

  bool testVal = false;
}

String getLauncherStateString(LauncherState s, Launcher? launcher) {
  String v = launcher?.localAppVersion?.getDisplayValue() ?? "";
  switch (s) {
    case LauncherState.canDownload:
      return " DOWNLOAD ";
    case LauncherState.canUpdate:
      return " UPDATE ";
    case LauncherState.canRun:
      return " PLAY ";
    case LauncherState.waiting:
      return "Waiting";
    case LauncherState.downloading:
      return "Downloading " + v;
    case LauncherState.installing:
      return "Installing";
    case LauncherState.uninstalling:
      return "Uninstalling";
    case LauncherState.updating:
      return "Updating to " + v;
    case LauncherState.running:
      return "Running";
    case LauncherState.connecting:
      return "Connecting";
    case LauncherState.preparingUpdate:
      return "Preparing update";
  }
}

Future showErrorRetryDialog(
    {required LauncherView widget,
    required String message,
    String title = "Ops, Something went wrong"}) async {
  if (widget.showUI) {
    return await FlutterPlatformAlert.showCustomAlert(
        positiveButtonTitle: "Try again",
        windowTitle: title,
        text: message,
        iconStyle: IconStyle.error);
  } else
    return Future.delayed(Duration(milliseconds: 50)).then((v) =>
        showErrorRetryDialog(message: message, title: title, widget: widget));
}

Future showCustomDialog(
    {required LauncherView widget,
    required String message,
    String title = "Ops, Something went wrong",
    String positiveButtonTitle = "",
    String neutralButtonTitle = "",
    String negativeButtonTitle = "",
    IconStyle iconStyle = IconStyle.information}) async {
  if (widget.showUI) {
    return await FlutterPlatformAlert.showCustomAlert(
        positiveButtonTitle: positiveButtonTitle,
        neutralButtonTitle: neutralButtonTitle,
        negativeButtonTitle: negativeButtonTitle,
        windowTitle: title,
        text: message,
        iconStyle: iconStyle);
  } else
    return Future.delayed(Duration(milliseconds: 50)).then((v) =>
        showCustomDialog(
            widget: widget,
            message: message,
            title: title,
            positiveButtonTitle: positiveButtonTitle,
            neutralButtonTitle: negativeButtonTitle,
            negativeButtonTitle: negativeButtonTitle,
            iconStyle: iconStyle));
}
