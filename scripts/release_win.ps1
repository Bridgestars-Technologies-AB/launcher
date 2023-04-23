
# rm -rf ../release/windows/
# mkdir ../release/windows
# nuget pack -OutputDirectory "../release/windows/" ../launcher.nuspec

$version="1.1.0"
..\squirrel\Squirrel.exe --releaseDir="../release/windows/out" --releasify ../release/windows/bridgestarslauncher.$version.nupkg
pause