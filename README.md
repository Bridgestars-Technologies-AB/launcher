# bridgestars_launcher

A launcher for the Bridgestars unity application.

## Getting Started

1. Install flutter [flutter_docs](https://docs.flutter.dev/get-started/install?gclid=CjwKCAjwyryUBhBSEiwAGN5OCCEYVlmlGoW26l56rdUzCRWFZIimvAs_iNHeEIiFRbOBxSB3LrkVnBoCU94QAvD_BwE&gclsrc=aw.ds)

### For MAC
3. On the top level, type: `make build_mac`
4. Follow the instructions

### For WINDOWS

1. may need to first download all releases from S3
2. On the top level, type: `make build_win PASS={certpass}` (certificate is located in a subfolder of the repo)
3. `make sign_win PASS={certpass}`
4. upload to S3
