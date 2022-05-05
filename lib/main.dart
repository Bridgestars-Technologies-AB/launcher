import 'dart:io';
import 'dart:ui';

//import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bridgestars_launcher/launcher.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

//import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_indicator/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (!kIsWeb &&
      (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {}
  await windowManager.ensureInitialized();
  DartVLC.initialize();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1620 / 2, 1080 / 2),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    minimumSize: Size(1620 / 4, 1080 / 4),
    maximumSize: Size(1620 / 1.5, 1080 / 1.5),
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.setAspectRatio(16.0 / 9.0);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(LauncherApp());
}

class LauncherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bridgestars LauncherAAA',
      theme: defaultTheme,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: HomePage(title: 'Bridgestars Launcher'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title = "asd"}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  //#region events
  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  void initState() {
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      print("STOPPING");
      if (showUI) {
        player.stop();
        await playOutroBeforeHiding();
      } else
        player.stop();
      await windowManager.destroy();
    }
  }

  //#endregion

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    await setup();
    //add constructor
  }

  void setMessage(String s) => setState(() {
        message = s;
      });

  void setLauncherState(LauncherState s, DownloadInfo? p) => setState(() {
        launcherState = s;
        launcherStateString = getLauncherStateString(s);
        progress = p;
      });

  String message = 'message';
  DownloadInfo? progress;
  Launcher? launcher;
  LauncherState launcherState = LauncherState.waiting;
  String launcherStateString = getLauncherStateString(LauncherState.waiting);
  bool showUI = false;
  bool showLoader = true;
  var player = Player(id: 124135);

  void showUIWhenVideoDone() async {
    await Future.delayed(const Duration(milliseconds: 2500), () {});
    setState(() {
      showUI = true;
    });
  }

  Future playOutroBeforeHiding() async {
    setState(() {
      showUI = false;
    });
    player.open(
      Media.asset('assets/shortOutro.mov'),
    );
    await Future.delayed(const Duration(milliseconds: 850), () {});
    player.stop();
  }

  // downloading logic is handled by this method

  Future setup() async {
    print("setup");
    player.open(
      Media.asset('assets/shortIntro.mov'),
    );
    Future.delayed(const Duration(milliseconds: 2500), () {})
        .then((value) => player.stop());
    showUIWhenVideoDone();
    //stopVideoWhenDone();
    //launcher = await Launcher.create(setLauncherState);
    //var l  = launcher!;
    //await Process.run('open', ["-a", "finder", l.root]).then((result) {
    //  stdout.write(result.stdout);
    //  stderr.write(result.stderr);
    //});
    //TODO Check version
  }

  Future handleBtnPress() async {
    if (launcher == null) return;
    await launcher!.handleBtnPress();
  }

  _HomePageState() {
    setup();
  }

  //gets the applicationDirectory and path for the to-be downloaded file

  // which will be used to save the file to that path in the downloadFile method

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context)
        .size
        .width; // * MediaQuery.of(context).devicePixelRatio;
    var height = MediaQuery.of(context)
        .size
        .height; // * MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {  },
        //   backgroundColor: defaultTheme.scaffoldBackgroundColor,
        //   child: Icon(Icons.now_widgets_outlined),
        //
        // ),
        body: Stack(
      children: [
        Video(
          player: player,
          //height: 360,
          //width: 640,
          scale: 1.0, // default
          showControls: false, // default
          playlistLength: 1,
        ),
        if (showUI)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              Padding(padding: EdgeInsets.only(top: height/50)
                  ,child: Text(launcherStateString, style: TextStyle(fontSize: width/60)))
            ])
          ])
      ],
    ));
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

showAlertDialog(BuildContext context, String title, String message,
    List<Text> btnTexts, List<Function()> btnActions) {
  if (btnTexts.length != btnActions.length)
    throw new ArgumentError("nbr of actions must be equal to nbr of btn texts");

  var btns = btnActions.asMap().entries.map((e) => TextButton(
      onPressed: () {
        Navigator.of(context).pop(); //pop dialog
        e.value(); //run btnAction
      },
      child: btnTexts.elementAt(e.key)));

// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: btns.toList(),
  );

// show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

PopupMenuItem _buildPopupMenuItem(String title,
    {IconData iconData = Icons.print}) {
  return PopupMenuItem(
    child: Row(
      children: [
        Icon(
          iconData,
          color: Colors.black,
        ),
        Text(title),
      ],
    ),
  );
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

// UNINSTALL DIALOG
//
// TextButton(
//
// child: Text("Uninstall", style: TextStyle(color: Colors.white),),
//   onPressed: () async {
//   try{
//     showAlertDialog(context, "Alert", "Are you sure you want to uninstall?",[Text("Cancel"), Text("Uninstall", style: TextStyle(color: Colors.red),)], [() => {}, () async {
//       await launcher?.uninstall();
//       launcher?.updateState();
//     }]);
//   }
//   catch (e) {
//     setMessage(e.toString());
//     throw Exception(e);
//     }
//   },//launcher.handleBtnPress(),
// ),
