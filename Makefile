main:
	echo "available commands: run_dev, build_windows, build_mac, release_windows"
dev:
	flutter run
build_windows:
	flutter run --dart-define=SQUIRREL_CERT_PASSWORD=$(PASS) -t installer_windows.dart
build_mac:
	flutter build macos