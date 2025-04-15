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
      
      zoomChannel.setMethodCallHandler { (call, result) in
        switch call.method {
            case "initZoom":
                DispatchQueue.main.async {
                    initZoom()
                    fflush(stdout)  // Ensures print output is flushed immediately
                }
            
             
              result("Initializing Zoom SDK...")
            default:
              result(FlutterMethodNotImplemented)
        }
      }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}


private func initZoom() {
  print("Initializing Zoom SDK...")
    let zoomSdk = ZoomSDK.shared()
    let initParams = ZoomSDKInitParams()
    initParams.zoomDomain = "zoom.us"
    
    let initResult = zoomSdk.initSDK(with: initParams)
    
    if initResult == ZoomSDKError_Success {
        print("✅ Zoom SDK initialized successfully")
        
        let authService = zoomSdk.getAuthService()
        authService.delegate = self

        let authContext = ZoomSDKAuthContext()
        authContext.jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJzZGtLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJtbiI6IjMyNzM1ODg2MTMiLCJyb2xlIjowLCJ0b2tlbkV4cCI6MTc0NDYzODc1MiwiaWF0IjoxNzQ0NjM1MTUyLCJleHAiOjE3NDQ2Mzg3NTJ9.-Qq9qTLY8bNDruLvXFjBmFbWtr2UVb7dKMniQ_NMGgg" // Input your JWT
        let authResult = authService.sdkAuth(authContext)
        print(authResult)
        
        if(authResult == ZoomSDKError_Success)
        {
            print("Successfully authenticated")
            
            let meetingService = zoomSdk.getMeetingService()
            if(meetingService){
                print("get meeting service")
                
                
                let joinParam = ZoomSDKJoinMeetingElements()
                joinParam.meetingNumber = 3273588613
                joinParam.password = "6SuCMB"
                joinParam.userType = ZoomSDKUserType_ZoomUser;
                joinParam.displayName = "Test User";
                
                let joinResult = meetingService?.joinMeeting(joinParam)
                if(joinResult == ZoomSDKError_Success)
                {
                    print("Joined meeting successfully")
                }
                else{
                    print("Failed to join meeting:")
                    print(joinResult)
                }
                
            }else{
                print("no meeting service")
            }
            
           
            
        }else{
            print("Failed to authenticate")
        }
        
        
    } else {
        print("❌ Zoom SDK failed to initialize: \(initResult.rawValue)")
    }
}

extension AppDelegate : ZoomSDKAuthDelegate {
    func onZoomSDKAuthReturn(_ returnValue: ZoomSDKAuthError) {
        if (returnValue == ZoomSDKAuthError_Success) {
            // SDK auth was successful
        }
    }

    func onZoomAuthIdentityExpired() {

    }
}

extension AppDelegate : ZoomSDKMeetingServiceDelegate {
    func onMeetingStatusChange(_ state: ZoomSDKMeetingStatus, meetingError error: ZoomSDKMeetingError, end reason: EndMeetingReason) {
        print("Status Change \(state.rawValue)")
        if (state == ZoomSDKMeetingStatus_InMeeting) {
            // You have successfully joined the meeting.
        }
    }
}
