import 'package:flutter/material.dart';
import '../tools.dart';

List<int> _colorInts = [
  0xFFF74040,
  0xFFDE3E42,
  0xFFC53B44,
  0xFF933547,
  0xFF612F4B,
  0xFF482C4D,
  0xFF2E294E,
  0xFF292540,
  0xFF232032];

Map<int, Color> appColors = {
  50: Color(_colorInts[0]),
  100:Color(_colorInts[0]),
  200:Color(_colorInts[1]),
  300:Color(_colorInts[2]),
  400:Color(_colorInts[3]),
  500:Color(_colorInts[4]),
  600:Color(_colorInts[5]),
  700:Color(_colorInts[6]),
  800:Color(_colorInts[7]),
  900:Color(_colorInts[8])
};

class MyTheme {
  static final ThemeData defaultTheme = _buildMyTheme();

  static ThemeData _buildMyTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      accentColor: appColors[100],
      accentColorBrightness: Brightness.dark,

      primaryColor: appColors[500],
      primaryColorDark: appColors[700],
      primaryColorLight: appColors[400],
      primaryColorBrightness: Brightness.dark,

      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: appColors[100],
        textTheme: ButtonTextTheme.primary,
      ),

      scaffoldBackgroundColor: Colors.black38,
      cardColor: Colors.black38,
      textSelectionColor: appColors[400],
      backgroundColor: Colors.black38,

      textTheme: base.textTheme.copyWith(
          headline1: base.textTheme.headline1!.copyWith(color: Colors.white),
          bodyText1: base.textTheme.bodyText1!.copyWith(color: Colors.white)
      ),
    );
  }
}



//Map<int, Color> appColors =




ThemeData bridgestarsTheme = ThemeData(
    // This is the theme of your application.
    //
    // Try running your application with "flutter run". You'll see the
    // application has a blue toolbar. Then without quitting the app, try
    // changing the primarySwatch below to Colors.green and then invoke
    // "hot reload" (press "r" in the console where you ran "flutter run",
    // or simply save your changes to "hot reload" in a Flutter IDE).
    // Notice that the counter didn't reset back to zero; the application
    // is not restarted.
    brightness: Brightness.dark,
    primaryColor: Colors.lightBlue[800],
    accentColor: Colors.cyan[600],
    fontFamily: 'Georgia',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),
      bodyText2: TextStyle(fontSize: 18.0, fontFamily: 'Hind'),
    ),

    primarySwatch: Colors.red
    // MaterialColor(_colorInts[4], <int, Color>{
    //   50: Color(_colorInts[0]),
    //   100:Color(_colorInts[0]),
    //   200:Color(_colorInts[1]),
    //   300:Color(_colorInts[2]),
    //   400:Color(_colorInts[3]),
    //   500:Color(_colorInts[4]),
    //   600:Color(_colorInts[5]),
    //   700:Color(_colorInts[6]),
    //   800:Color(_colorInts[7]),
    //   900:Color(_colorInts[8])
    //   }),
  );