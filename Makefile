main:
	echo "available commands: build_windows, build_mac, run" 
dev:
	flutter run
build_win:
ifndef PASS
$(error PASS is not set)
endif
	echo $(PASS) > certpass.txt	
	flutter clean
	flutter build windows
	flutter run -t squirrel_bin/installer_windows.dart
sign_win:
	.\squirrel_bin\signtool.exe sign /a /f ".\squirrel_bin\certificate.pfx" /p sQq2TOu0xQJ89l9qMhHFW3eO22X8T /v /fd sha256 /tr http://timestamp.digicert.com /td sha256 /n "Bridgestars Technologies Sweden AB" .\release_win\Setup.exe
build_mac:
	flutter clean
	flutter build macos --split-per-abi
	cp -r build/macos/Build/Products/Release/Bridgestars.app release/Bridgestars.app
