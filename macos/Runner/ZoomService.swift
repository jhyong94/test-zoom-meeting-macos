import Foundation
import ZoomSDK

class ZoomService: NSObject {
    static let shared = ZoomService()

    private override init() {}

    func initializeSDK() {
        print("================================================")
        print("Enter initializeSDK Function")

        let zoomSdk = ZoomSDK.shared()
        let initParams = ZoomSDKInitParams()
        initParams.enableLog = true
        initParams.zoomDomain = "zoom.us"

        let initResult = zoomSdk.initSDK(with: initParams)

        guard initResult == ZoomSDKError_Success else {
            print("❌ Zoom SDK failed to initialize: \(initResult.rawValue)")
            return
        }

        print("✅ Zoom SDK initialized successfully")

        let authService = zoomSdk.getAuthService()
        authService.delegate = self

        print("Auth service available")

        let authContext = ZoomSDKAuthContext()
        authContext.jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJzZGtLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJtbiI6IjMyNzM1ODg2MTMiLCJyb2xlIjowLCJ0b2tlbkV4cCI6MTc0NDY4NzQ2NSwiaWF0IjoxNzQ0NjgzODY1LCJleHAiOjE3NDQ2ODc0NjV9.hPu-gaDfwdrcTjHIxvrn8wSsWT1lfW0NN9n9onasf70"

        let authResult = authService.sdkAuth(authContext)

        print("Run authService.sdkAuth Result: \(authResult.rawValue)")
        if(authResult != ZoomSDKError_Success){
            print("❌ authService.sdkAuth failed")
            print(authResult.rawValue)
        }
        print("================================================")
    }

    private func joinMeeting() {
        print("================================================")
        print("Enter joinMeeting Function");

        guard let meetingService = ZoomSDK.shared().getMeetingService() else {
            print("❌ No meeting service available")
            return
        }
        print("Meeting service available")
        meetingService.delegate = self

        let joinParam = ZoomSDKJoinMeetingElements()
        joinParam.meetingNumber = 3273588613
        joinParam.password = "6SuCMB"
        joinParam.userType = ZoomSDKUserType_WithoutLogin
        joinParam.displayName = "Test User"
        joinParam.webinarToken = nil;
        joinParam.customerKey = nil;
        joinParam.isDirectShare = false;
        joinParam.displayID = 0;
        joinParam.isNoVideo = false;
        joinParam.isNoAudio = false;
        joinParam.vanityID = nil;
        joinParam.zak = nil;

        let joinResult = meetingService.joinMeeting(joinParam)

        if joinResult == ZoomSDKError_Success {
            print("✅ Joined meeting successfully")
        } else {
            print("❌ Failed to join meeting: \(joinResult.rawValue)")
        }
        
        print("================================================")
    }
}

extension ZoomService: ZoomSDKAuthDelegate {
    func onZoomSDKAuthReturn(_ returnValue: ZoomSDKAuthError) {
        DispatchQueue.main.async {
            print("================================================")
            print("Enter onZoomSDKAuthReturn")
            print("Zoom SDK Auth returned: \(returnValue.rawValue)")
            print(returnValue)
            
            if returnValue == ZoomSDKAuthError_Success {
                self.joinMeeting()
            } else {
                print("❌ Authentication failed")
            }

            print("================================================")
            fflush(stdout)
        }
    }

    func onZoomAuthIdentityExpired() {
        
        DispatchQueue.main.async {
            print("⚠️ Zoom Auth Identity Expired")
            fflush(stdout)
        }
    }
}

extension ZoomService: ZoomSDKMeetingServiceDelegate {
    func onMeetingStatusChange(_ state: ZoomSDKMeetingStatus, meetingError error: ZoomSDKMeetingError, end reason: EndMeetingReason) {
        
        DispatchQueue.main.async {
            print("Meeting status changed: \(state.rawValue)")
            fflush(stdout)
        }
    }
}
