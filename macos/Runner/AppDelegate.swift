import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
    override func applicationWillFinishLaunching(_ aNotification: Notification) {

    }
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               //call any function
            //LetsMove.shared.moveToApplicationsFolderIfNecessary()
        }
    }
}
