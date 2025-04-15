import Cocoa
import FlutterMacOS
import ZoomSDK

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let zoomChannel = FlutterMethodChannel(
      name: "zoom_sdk",
      binaryMessenger: flutterViewController.engine.binaryMessenger)

    zoomChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      switch call.method {
      case "initZoom":
        DispatchQueue.main.async {
            self.initZoom()
            fflush(stdout)
        }
        result("Initializing Zoom SDK...")
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }

  private func initZoom() {
      ZoomService.shared.initializeSDK()
  }
}
