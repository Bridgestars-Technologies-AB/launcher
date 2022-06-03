#rm -f release/macos/*.dmg && mkdir -p release && mkdir -p release/macos && flutter clean && flutter pub get && flutter build macos --release 
rm -f release/macos/*.dmg
mv "build/macos/Build/Products/Release/Bridgestars.app" "release/macos/pre/Bridgestars.app"
# Create the DMG
create-dmg \
  --volname "Bridgestars Installer" \
  --background "assets/dmg_background.png" \
  --window-pos 200 120 \
  --icon-size 64 \
  --icon "Bridgestars.app" 150 190 \
  --hide-extension "Bridgestars.app" \
  --app-drop-link 350 185 \
  "release/macos/Application-Installer.dmg" \
  "release/macos/pre/"