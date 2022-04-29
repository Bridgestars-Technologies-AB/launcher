import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bridgestars_launcher/launcher.dart';


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
  runApp(LauncherApp());
}

class LauncherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bridgestars LauncherAAA',
      theme:defaultTheme,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: HomePage(title: 'File Download With Progress'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title="asd"}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  Phase phase = Phase.begin;
  String message = '';
  String progress = '';

  void setPhase(Phase p) => setState(() {
    phase = p;
  });
  void setMessage(String s) => setState(() {
    message = s;
  });

  void setProgress(ProgressInfo p) => setState(() {
    progress = '${p.progress}%  ${p.speed}  ${p.timeLeft}';
  });
  // downloading logic is handled by this method



  Future downloadAndRun() async {
    var l = await Launcher.create();

    await Process.run('open', ["-a", "finder", l.root]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });


    //TODO Check version

    if(!await l.executableExists()){
      if(!await l.downloadZipExists()){
        await l.download((progress) => {
          setProgress(progress)
        });
      }
      await l.install();
    }
    await l.runApp();
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
                Text(progress),
                Text(getPhaseDescription()),
                Text(message, style: TextStyle(color: defaultTheme.accentColor))
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () async {

              try{
                await downloadAndRun();
              }catch(e){
                setMessage(e.toString());
              }

              //downloadFile(uri, filename);
            }),
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
