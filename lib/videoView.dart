import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:window_manager/window_manager.dart';

class VideoView extends StatefulWidget {
  final Function(bool) onShowUIChanged;

  VideoView({Key? key, required this.onShowUIChanged}) : super(key: key){}

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<VideoView> with WindowListener {
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

  bool showUI = false;

  void setShowUI(bool b) {
    setState(() {
      showUI = b;
    });
    widget.onShowUIChanged(b);
  }

  var player = Player(id: 124135);

  void showUIWhenVideoDone() async {
    await Future.delayed(const Duration(milliseconds: 2500), () {});
    setShowUI(true);
  }

  Future playOutroBeforeHiding() async {
    setShowUI(false);
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

  //gets the applicationDirectory and path for the to-be downloaded file

  // which will be used to save the file to that path in the downloadFile method

  @override
  Widget build(BuildContext context) {
    return Video(
      player: player,
      //height: 360,
      //width: 640,
      scale: 1.0, // default
      showControls: false, // default
      playlistLength: 1,
    );
  }
}
