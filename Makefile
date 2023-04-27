main:
	echo "available commands: build_windows, build_mac, run" 
dev:
	flutter run
build_win:
	echo $(PASS) > certpass.txt	
	flutter run -t installer_windows.dart
sign_win:
	.\vendor\signtool.exe sign /a /f ".\vendor\certificate.pfx" /p sQq2TOu0xQJ89l9qMhHFW3eO22X8T /v /fd sha256 /tr http://timestamp.digicert.com /td sha256 /n "Bridgestars Technologies Sweden AB" .\release\windows\Setup.exe
build_mac:
	flutter build macos