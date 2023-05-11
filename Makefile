main:
	echo "available commands: build_windows, build_mac, run" 
dev:
	flutter run
build_win:
	echo "DONT FORGET TO ENTER 'PASS' VARIABLE"
	echo $(PASS) > certpass.txt	
	flutter clean
	flutter build windows
	flutter run -t squirrel_bin/installer_windows.dart
sign_win:
	.\squirrel_bin\signtool.exe sign /a /f ".\squirrel_bin\certificate.pfx" /p sQq2TOu0xQJ89l9qMhHFW3eO22X8T /v /fd sha256 /tr http://timestamp.digicert.com /td sha256 /n "Bridgestars Technologies Sweden AB" .\release_win\Setup.exe
build_mac:
	flutter clean
	flutter build macos
	@echo ""
	@echo "Open macos/Runner.xcworkspace in xcode"
	@read -s -n 1 -p "Press any key to continue . . ."
	@echo "In xcode menu, go to Product->archive to start archiving process"
	@read -s -n 1 -p "Press any key to continue . . ."
	@echo "Go to Window->Organizer and confirm that version with new name has been created. Select version and press Distribute App->Developer Id->confirm->upload->upload etc"
	@read -s -n 1 -p "Press any key to continue . . ."
	@echo "Wait for notarization to finish"
	@read -s -n 1 -p "Press any key to continue . . ."
	@echo "Export archive as app to folder 'release_mac', compress and keep .app, rename it to 'bridgestars-macos-x.x.x.zip"
	@read -s -n 1 -p "Press any key to continue . . ."
	@echo "Generating appcast.xml and delta updates...."
	Sparkle/bin/generate_appcast release_mac
	appdmg dmg-config.json release_mac/Bridgestars.app
	

