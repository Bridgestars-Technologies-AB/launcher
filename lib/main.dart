import 'dart:io';

import 'bitsdojo_window/lib/bitsdojo_window.dart';
import 'package:Bridgestars/videoView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

// import 'package:auto_updater/auto_updater.dart';
//import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'launcherView.dart';
import 'videoView.dart';

import 'package:media_kit/media_kit.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

late final navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<VideoViewState> videoKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();


  WindowOptions windowOptions = WindowOptions(
    size: Size(1620 / 2, 1080 / 2),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    minimumSize: Size(1620 * 0.4, 1080 * 0.4),
    maximumSize: Size(1620 / 1.5, 1080 / 1.5),
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.setAspectRatio(3.0 / 2.0);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  if (Platform.isWindows)
    doWhenWindowReady(() {
      //const initialSize = Size(600, 450);
      appWindow.minSize = Size(1620 * 0.4, 1080 * 0.4);
      appWindow.size = Size(1620 / 2, 1080 / 2);
      appWindow.maxSize = Size(1620 / 1.5, 1080 / 1.5);
      //appWindow.alignment = Alignment.center;
      appWindow.show();
    });

  await SentryFlutter.init((options) {
    options.dsn =
        'https://0fa41ac90dce42e8af98c5b60d24ee7a@o4505084744433664.ingest.sentry.io/4505086445027328';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
  }, appRunner: init);
}

void init() async {
  MediaKit.ensureInitialized();
  if (!kIsWeb &&
      (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {}

  if (Platform.isWindows) {
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
  // else if(Platform.isMacOS){
  //   String feedURL = 'https://bridgestars-static-host.s3.eu-north-1.amazonaws.com/launcher/mac/RELEASES.xml';
  //   await autoUpdater.setFeedURL(feedURL);
  //   await autoUpdater.checkForUpdates();
  //   await autoUpdater.setScheduledCheckInterval(3600);
  // }


  runApp(MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: LauncherApp()));
}

class LauncherApp extends StatefulWidget {
  const LauncherApp({Key? key}) : super(key: key);

  @override
  _LauncherState createState() => _LauncherState();
}

class _LauncherState extends State<LauncherApp> {
  bool showUI = false;
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bridgestars Launcher',
        theme: defaultTheme,
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        // ),
        home: Scaffold(
          body: Stack(
            children: [
              VideoView(
                  key: videoKey,
                  onShowUIChanged: (b) => setState(() {
                        print("SHOW UI ");
                        print(b);
                        showUI = b;
                      })),
              LauncherView(showUI: showUI, videoViewKey: videoKey),
              if (Platform.isWindows)
                WindowTitleBarBox(
                    child: Row(
                  children: [Expanded(child: MoveWindow()), WindowButtons()],
                ))
            ],
          ),
        ));
  }
}

final closeButtonColors = WindowButtonColors(
    mouseOver: Color(0xFFD32F2F),
    mouseDown: Color(0xFFB71C1C),
    iconNormal: Color(0xFFFFFFFF),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CloseWindowButton(colors: closeButtonColors),
      ],
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

// UNINSTALL DIALOG
//
