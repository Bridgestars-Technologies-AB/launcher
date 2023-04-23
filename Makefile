main:
	echo "available commands: run_dev, build_windows, build_mac, release_windows"
dev:
	flutter run
build_windows:
	flutter build windows
build_mac:
	flutter build macos

release_windows:
	flutter clean
	flutter pub get
	flutter build windows

pack:
	nuget pack -OutputDirectory "release/windows/" launcher.nuspec
