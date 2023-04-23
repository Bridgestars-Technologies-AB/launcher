main:
	echo "available commands: build_windows, build_mac, run" 
dev:
	flutter run
build_windows:
	echo "PASS=your_password"
	flutter run -t installer_windows.dart --dart-define=SQUIRREL_CERT_PASSWORD=$(PASS)
build_mac:
	flutter build macos