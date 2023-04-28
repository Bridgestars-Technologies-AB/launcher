import '../../../bitsdojo_window_platform_interface/lib/bitsdojo_window_platform_interface.dart';
import '../../../bitsdojo_window_platform_interface/lib/method_channel_bitsdojo_window.dart';
import '../../../bitsdojo_window_windows/lib/bitsdojo_window_windows.dart';
import '../../../bitsdojo_window_linux/lib/bitsdojo_window_linux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool _platformInstanceNeedsInit = true;

void initPlatformInstance() {
  if (!kIsWeb) {
    if (BitsdojoWindowPlatform.instance is MethodChannelBitsdojoWindow) {
      if (Platform.isWindows) {
        BitsdojoWindowPlatform.instance = BitsdojoWindowWindows();
      } else if (Platform.isMacOS) {
      } else if (Platform.isLinux) {
        BitsdojoWindowPlatform.instance = BitsdojoWindowLinux();
      }
    }
  } else {
    BitsdojoWindowPlatform.instance = BitsdojoWindowPlatformNotImplemented();
  }
}

BitsdojoWindowPlatform get _platform {
  var needsInit = _platformInstanceNeedsInit;
  if (needsInit) {
    initPlatformInstance();
    _platformInstanceNeedsInit = false;
  }
  return BitsdojoWindowPlatform.instance;
}

void doWhenWindowReady(VoidCallback callback) {
  _platform.doWhenWindowReady(callback);
}

DesktopWindow get appWindow {
  return _platform.appWindow;
}
