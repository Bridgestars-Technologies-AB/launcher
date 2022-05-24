import 'dart:io';
import 'dart:ui';

//import 'package:desktop_window/desktop_window.dart';
import 'package:bridgestars_launcher/videoView.dart';
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

import 'launcherView.dart';
import 'videoView.dart';

late final navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<VideoViewState> videoKey = GlobalKey();

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
  await windowManager.setAspectRatio(3.0 / 2.0);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    home:LauncherApp()
  ));

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
        title: 'Bridgestars LauncherAAA',
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
              LauncherView(showUI: showUI, videoViewKey: videoKey)
            ],
          ),
        ));
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

