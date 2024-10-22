import 'dart:io';
import 'dart:isolate';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'launcher.dart';

class VideoView extends StatefulWidget {
  final Function(bool) onShowUIChanged;
  bool _triggerHideSequence = false;

  VideoView(
      {Key? key,
      required this.onShowUIChanged,
      bool triggerHideSequence = false})
      : super(key: key) {
    _triggerHideSequence = triggerHideSequence;
  }

  @override
  VideoViewState createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> with WindowListener {
  final Player player = Player();
  VideoController? controller;

  bool showUI = false;

  void setShowUI(bool b) {
    setState(() {
      showUI = b;
    });
    widget.onShowUIChanged(b);
  }

  Future playOutroAndHide(
      Function? startGameCallback, Function? setLauncherState,
      {bool macPlay = false}) async {
    if (!Platform.isMacOS || macPlay) {
      setShowUI(false);
      await player.open(Media('asset:///assets/shortOutro.mov'), play: true);
      // await player.setRate(-1.0);
      // await player.play();
      await Future.delayed(const Duration(milliseconds: 1000), () {});
      await player.pause();
    }
    if (startGameCallback != null) {
      if (Platform.isMacOS) {
        // await windowManager.minimize();
        if (!macPlay) {
          if (setLauncherState != null) setLauncherState(LauncherState.running);
          Future.delayed(const Duration(milliseconds: 5000), () {
            if (setLauncherState != null)
              setLauncherState(LauncherState.canRun);
          });
        }
        startGameCallback();
        // await windowManager.isAlwaysOnBottom();
        // await Future.delayed(const Duration(milliseconds: 1000), () {});
        return;
      }

      // if (Platform.isWindows)
      // await windowManager.setSkipTaskbar(false);
      // await windowManager.minimize();
      if (Platform.isWindows) {
        await windowManager.hide();
        if (setLauncherState != null) setLauncherState(LauncherState.running);
        Future.microtask(() async => startGameCallback());
        if (setLauncherState != null) setLauncherState(LauncherState.canRun);
      }
    }
    // await Future.delayed(const Duration(milliseconds: 200), () {});
    // await Future.delayed(const Duration(milliseconds: 4000), () {});
    //await showWithBackground();
    // await windowManager.setSkipTaskbar(false);
  }

  Future showWithBackground() async {
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
    await windowManager.restore();
    await player.open(
      Media('asset:///assets/shortIntro.mov'),
    );
    player.play();
    //player.seek(Duration(seconds: 4));
    setShowUI(true);
  }

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
    super.initState();
    Future.microtask(() async {
      /// Create a [VideoController] to show video output of the [Player].
      controller = await VideoController.create(player);
      await windowManager.setPreventClose(true);
      await player.open(Media('asset://assets/shortIntro.mov'));

      setState(() {
        showUI = false;
      });
      await player.play();
      Future.delayed(const Duration(milliseconds: 2500), () {})
          .then((value) async {
        await player.pause();
      // await controller?.dispose();
      // await player.dispose();
        setShowUI(true);
      });
    }); // Add this line to override the default close handler
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    // Future.microtask(() async {
    //   /// Release allocated resources back to the system.
    //   await controller?.dispose();
    //   await player.dispose();
    // });
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    // print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      if (showUI) {
        if (player.state.playing) player.pause();
        await playOutroAndHide(() async {
          await windowManager.setPreventClose(false);
          dispose();
          await windowManager.close();
        }, null, macPlay: true);
      } else {
        dispose();
        await windowManager.setPreventClose(false);
        await windowManager.close();
      }
      // await Future.delayed(const Duration(milliseconds: 2000), () {});
    } else
      await windowManager.close();
  }

  //#endregion
  @override
  Widget build(BuildContext context) {
    return Video(controller: controller);
  }
}
