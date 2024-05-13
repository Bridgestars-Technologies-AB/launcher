# Mac + Windows game launcher

A launcher for the Bridgestars unity application.
- Game installation and updates
- Windows and MacOS compatible
- Launcher packaging and installation using windows/mac installer,
  - ask to place shortcut on desktop
  - ask to move itself to /apps folder (mac)
- Launcher updates using squirrel


Launcher can be downloaded and tested here [https://bridgestars.net/download](https://bridgestars.net/download)

![CleanShot 2024-05-13 at 08 34 02](https://github.com/Bridgestars-Technologies-AB/bridgestars-launcher/assets/31588188/4f3065b6-f57f-4b13-aa4a-5ef5e7779fd9)


- Open and close animations

![CleanShot 2024-05-13 at 08 42 24](https://github.com/Bridgestars-Technologies-AB/bridgestars-launcher/assets/31588188/69ef48b8-ace7-4e25-bd5b-0364cd053c09)



## Getting Started

1. Install flutter [flutter_docs](https://docs.flutter.dev/get-started/install?gclid=CjwKCAjwyryUBhBSEiwAGN5OCCEYVlmlGoW26l56rdUzCRWFZIimvAs_iNHeEIiFRbOBxSB3LrkVnBoCU94QAvD_BwE&gclsrc=aw.ds)


### For release deployment on MAC

3. On the top level, type: `make build_mac`
4. Follow the instructions

### For release deployment on WINDOWS

1. may need to first download all releases from S3
2. On the top level, type: `make build_win PASS={certpass}` (certificate is located in a subfolder of the repo)
3. `make sign_win PASS={certpass}`
4. upload to S3



### Disclaimer: 
Game download is just a normal zip file download + extraction, which is not resumable and does not work very well for large games. Keep this in mind if you want to use the code for your own game. 
