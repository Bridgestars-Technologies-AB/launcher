import 'dart:io';

import 'package:bridgestars_launcher/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'launcher.dart';

void _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
}

drawSettingsPanel(
    BuildContext context, Launcher? launcher, void Function() closeCallback) {
  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;

  return Stack(
    children: [
      SettingsList(
          platform: DevicePlatform.web,
          contentPadding: EdgeInsets.fromLTRB(
              width / 100, height / 50, width / 100, height / 10),
          lightTheme: SettingsThemeData(
              settingsListBackground: const Color(0xFF252525),
              titleTextColor: Colors.white,
              tileDescriptionTextColor: Colors.white,
              inactiveTitleColor: Colors.white10,
              settingsTileTextColor: Colors.white,
              settingsSectionBackground: const Color(0xFF454545),
              leadingIconsColor: Colors.white,
              tileHighlightColor: Colors.blue),
          //darkTheme: ,
          sections: [
            SettingsSection(
              title: Text('General'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  description: Text(
                      'Display information about the current game version'),
                  onPressed: (a) {
                    showAppInfoDialog(launcher?.localAppVersion, null);
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.cloud_download),
                  title: Text('Check for updates'),
                  description: Text('Manually check for new game updates'),
                  onPressed: (a) async {
                    var close = showLoadingDialog("Checking...");
                    await launcher?.refreshAppVersion();
                    await launcher?.updateState();
                    close();
                    if (launcher?.getState() == LauncherState.canUpdate)
                      showOkDialog(
                          "Update found",
                          launcher?.remoteAppVersion?.getDisplayValue() ??
                              "" + " can be installed now!",
                          "INSTALL", () async {
                        closeCallback();
                      });
                    else
                      showOkDialog(
                          "No update found",
                          "You already have the latest version!",
                          "OK",
                          () => {});
                  },
                ),
                SettingsTile.navigation(
                  enabled: true,
                  leading: Icon(Icons.delete),
                  title: Text('Remove Game Files'),
                  description: Text(
                      'Does the game not work as expected? Try cleaning and reinstalling.'),
                  onPressed: (a) async {
                    [
                      LauncherState.downloading,
                      LauncherState.installing,
                      LauncherState.preparingUpdate
                    ].contains(launcher?.getState())
                        ? showAlertDialog(
                            "Download in progress",
                            "Can't remove game files while downloading.",
                            [Text("Cancel")],
                            [() => {}])
                        : await launcher?.canUninstall()
                            ? showAlertDialog(
                                "Are you sure?",
                                "Do you want to remove the game files?\n\nThis will not delete your in-game settings.",
                                [
                                    Text("Cancel"),
                                    Text(
                                      "Remove Files",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  ],
                                [
                                    () => {},
                                    () async {
                                      var close = showLoadingDialog(
                                          "deleting files...");
                                      await launcher?.uninstall();
                                      await launcher?.refreshAppVersion();
                                      await launcher?.updateState();
                                      close();
                                      showOkDialog(
                                          "Done",
                                          "Game files have been removed.",
                                          "OK",
                                          () => {/* do something? */});
                                    }
                                  ])
                            : showAlertDialog(
                                "Nothing here",
                                "No more game files can be removed.",
                                [Text("Cancel")],
                                [() => {}]);
                  },
                ),
              ],
            )
          ]),
      Align(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, height / 20, 0, height / 100),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text("Find us on", style: TextStyle(fontSize: height / 30)),
            Container(height: height / 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 6),
                IconButton(
                  icon:
                      Icon(FontAwesomeIcons.facebook, color: Color(0xFF7390cb)),
                  iconSize: height / 20,
                  onPressed: () {
                    _launchUrl(
                        "https://www.facebook.com/BridgestarsTechnologies");
                  },
                ),
                Spacer(flex: 1),
                IconButton(
                  icon:
                      Icon(FontAwesomeIcons.discord, color: Color(0xFF8690f5)),
                  iconSize: height / 20,
                  onPressed: () {
                    _launchUrl(
                        "https://discord.com/invite/BmZce5wb?utm_source=Discord%20Widget&utm_medium=Connect");
                  },
                ),
                Spacer(flex: 1),
                IconButton(
                  icon: Icon(FontAwesomeIcons.instagram,
                      color: Color(0xFFd669a6)),
                  iconSize: height / 20,
                  onPressed: () {
                    _launchUrl("https://www.instagram.com/bridgestars/");
                  },
                ),
                Spacer(flex: 6),
              ],
            ),
          ]),
        ),
        alignment: Alignment.bottomCenter,
      ),
      Padding(
          padding: EdgeInsets.all(width / 70),
          child: Align(
            child: IconButton(
              onPressed: () {
                closeCallback();
              },
              icon: Icon(
                  Platform.isWindows ? Icons.arrow_back_ios_new : Icons.close,
                  color: Colors.white),
              tooltip: "Close",
              //mouseCursor: SystemMouseCursors.click,
              iconSize: height / 18,
            ),
            alignment:
                Platform.isWindows ? Alignment.topLeft : Alignment.topRight,
          )),
    ],
  );
}
