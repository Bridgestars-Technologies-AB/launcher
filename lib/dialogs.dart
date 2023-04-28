import 'dart:io';

import 'package:Bridgestars/launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'launcherView.dart';
import 'main.dart';

Function showLoadingDialog(String text) {
  if (navigatorKey.currentContext == null)
    throw new Exception("Something not set up right");

  var context = navigatorKey.currentContext!;

  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 1,
        backgroundColor: const Color(0xFF121212),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Padding(
            padding: EdgeInsets.all(height / 45),
            child: Container(
                height: height * 0.25,
                width: height * 0.2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(flex: 1),
                      Container(
                        width: width / 20,
                        height: width / 20,
                        alignment: Alignment.center,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballRotateChase,
                          colors: const [Colors.white70],
                        ),
                      ),
                      Spacer(flex: 2),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: height / 20, color: Colors.white),
                      ),
                      Spacer(flex: 1),
                    ]))),
      );
    },
  );

  return () => Navigator.of(context).pop();
}

showOkDialog(
    String title, String text, String btnText, Function() closeCallback) {
  if (navigatorKey.currentContext == null)
    throw new Exception("Something not set up right");

  var context = navigatorKey.currentContext!;

  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 1,
        backgroundColor: const Color(0xFF121212),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Padding(
            padding: EdgeInsets.all(height / 45),
            child: Container(
                height: height * 0.25,
                width: height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: height / 25, color: Colors.white),
                    ),
                    Spacer(flex: 1),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: height / 30, color: Colors.white),
                    ),
                    Spacer(flex: 2),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(
                              //borderRadius: BorderRadius.circular(height/30),
                              side: BorderSide(color: Colors.red)),
                          primary: Color.fromARGB(255, 255, 100, 100),
                          //shadowColor: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        onPressed: () {
                          closeCallback();
                          Navigator.of(context).pop();
                        },
                        child: Text(" " + btnText + " ",
                            style: TextStyle(
                                fontSize: height / 33, color: Colors.white)))
                  ],
                ))),
      );
    },
  );

  return () => Navigator.of(context).pop();
}

showAppInfoDialog(Version? v, Function()? closeCallback) {
  if (navigatorKey.currentContext == null)
    throw new Exception("Something not set up right");

  var context = navigatorKey.currentContext!;

  var width = MediaQuery.of(context)
      .size
      .width; // * MediaQuery.of(context).devicePixelRatio;
  var height = MediaQuery.of(context).size.height;

  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 1,
        backgroundColor: const Color(0xFF121212),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Padding(
            padding: EdgeInsets.all(height / 45),
            child: Container(
              height: height * 0.65,
              width: width * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/app_icon.ico', height: height / 6),
                  Text(
                    "Bridgestars for " +
                        (Platform.isMacOS ? "MacOS" : "Windows"),
                    style:
                        TextStyle(fontSize: height / 35, color: Colors.white),
                  ),
                  Text(
                    v?.getDisplayValue() ?? "No version number found",
                    style:
                        TextStyle(fontSize: height / 35, color: Colors.white),
                  ),
                  Container(height: height / 100),
                  Container(
                    constraints: BoxConstraints.expand(height: height / 3.5),
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                width / 30, 0, width / 30, 0),
                            child: Text(v?.getInfo() ?? "No update notes found",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: height / 40,
                                    color: Colors.white)))),
                  ),
                  Container(height: height / 100),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(
                            //borderRadius: BorderRadius.circular(height/30),
                            side: BorderSide(color: Colors.red)),
                        primary: Color.fromARGB(255, 255, 100, 100),
                        //shadowColor: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      onPressed: () {
                        if (closeCallback != null) closeCallback();
                        Navigator.of(context).pop();
                      },
                      child: Text(" OK ",
                          style: TextStyle(
                              fontSize: height / 33, color: Colors.white)))
                ],
              ),
            )),
      );
    },
  );
}

showAlertDialog(String title, String message, List<Text> btnTexts,
    List<Function()> btnActions) {
  if (btnTexts.length != btnActions.length)
    throw new ArgumentError("nbr of actions must be equal to nbr of btn texts");

// set up the AlertDialog

// show the dialog
  if (navigatorKey.currentContext == null)
    throw new Exception("Something not set up right");
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: btnActions
            .asMap()
            .entries
            .map((e) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //pop dialog
                  return e.value(); //run btnAction
                },
                child: btnTexts.elementAt(e.key)))
            .toList(),
      );
    },
  );
}

Future showErrorDialog(
    {required LauncherView widget,
    required String message,
    String title = "Ops, Something went wrong",
    String btn_text = "OK"}) async {
  if (widget.showUI) {
    return await FlutterPlatformAlert.showCustomAlert(
        positiveButtonTitle: "OK",
        windowTitle: title,
        text: message,
        iconStyle: IconStyle.error);
  } else
    return Future.delayed(Duration(milliseconds: 50)).then(
        (v) => showErrorDialog(message: message, title: title, widget: widget));
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
