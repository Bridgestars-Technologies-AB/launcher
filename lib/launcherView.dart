


import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:window_manager/window_manager.dart';

import 'launcher.dart';

class LauncherView extends StatefulWidget {
  LauncherView({Key? key, required this.showUI}) : super(key: key);

  final bool showUI;

  @override
  _LauncherViewState createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> with WindowListener {

  void setMessage(String s) =>
      setState(() {
        message = s;
      });

  void setLauncherState(LauncherState s, DownloadInfo? p) =>
      setState(() {
        launcherState = s;
        launcherStateString = getLauncherStateString(s);
        progress = p;
      });

  String message = 'message';
  DownloadInfo? progress;
  Launcher? launcher;
  LauncherState launcherState = LauncherState.waiting;
  String launcherStateString = getLauncherStateString(LauncherState.waiting);
  bool showLoader = true;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context)
        .size
        .width; // * MediaQuery.of(context).devicePixelRatio;
    var height = MediaQuery.of(context)
        .size
        .height; // * MediaQuery.of(context).devicePixelRatio;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if(widget.showUI) Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: height*0.5),
        if (showLoader) Container(
          width: width/20,
          height: width/20,
          alignment: Alignment.center,
          child: LoadingIndicator(
            indicatorType: Indicator.ballRotateChase,

            /// Required, The loading type of the widget
            colors: const [Colors.white],

            /// Optional, The color collections

            //strokeWidth: 2, /// Optional, The stroke of the line, only applicable to widget which contains line
            //backgroundColor: Colors.black,      /// Optional, Background of the widget
            //pathBackgroundColor: Colors.black
          ),
        ),
        Container(height: height/30),
        Text(launcherStateString, style: TextStyle(fontSize: width/60, color: Colors.white70)),
      ])
    ]);
  }

}



String getLauncherStateString(LauncherState s) {
  switch (s) {
    case LauncherState.canDownload:
      return "Download";
    case LauncherState.canInstall:
      return "Install";
    case LauncherState.canUpdate:
      return "Update";
    case LauncherState.canRun:
      return "Start";
    case LauncherState.waiting:
      return "Waiting";
    case LauncherState.downloading:
      return "Downloading";
    case LauncherState.installing:
      return "Installing";
    case LauncherState.uninstalling:
      return "Uninstalling";
    case LauncherState.updating:
      return "Updating";
    case LauncherState.running:
      return "Running";
  }
}