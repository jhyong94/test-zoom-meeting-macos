import Foundation
import ZoomSDK

class ZoomService: NSObject {
    static let shared = ZoomService()
    private var isInitialized = false
    
    // Your Zoom SDK credentials
    private let appKey = "AbXWKeCLRyCZrQDQXEm1Q"
    private let appSecret = "CgSYWqcKn78FYaqaAdug22Ei4jRrO5AB"
    
    // Store auth service as a property to keep strong reference
    private var authService: ZoomSDKAuthService?
    
    private override init() {
        super.init()
    }
    
    deinit {
        // Clean up resources when this object is deallocated
        cleanUp()
    }
    
    private func cleanUp() {
        if let authService = authService {
            authService.delegate = nil
            self.authService = nil
        }
    }

    func initializeSDK() {
        print("================================================")
        print("Enter initializeSDK Function")

        // Get the Zoom SDK instance
        let zoomSdk = ZoomSDK.shared()
        
        // Initialize SDK if not already initialized
        if !isInitialized {
            let initParams = ZoomSDKInitParams()
            initParams.enableLog = true
            initParams.zoomDomain = "zoom.us"

            let initResult = zoomSdk.initSDK(with: initParams)

            guard initResult == ZoomSDKError_Success else {
                print("❌ Zoom SDK failed to initialize: \(initResult.rawValue)")
                return
            }
            
            isInitialized = true
            print("✅ Zoom SDK initialized successfully")
        } else {
            print("✅ Zoom SDK already initialized")
        }

        // Get the auth service
        authService = zoomSdk.getAuthService()
        
        guard let authService = authService else {
            print("❌ Failed to get auth service")
            return
        }
        
        // Set ourselves as the delegate
        authService.delegate = self
        print("✅ Auth service available and delegate set")
        
        // Create the auth context with the JWT token
        let authContext = ZoomSDKAuthContext()
        
        // Try with a fresh JWT token
        let jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJzZGtLZXkiOiJBYlhXS2VDTFJ5Q1pyUURRWEVtMVEiLCJtbiI6IjMyNzM1ODg2MTMiLCJyb2xlIjowLCJ0b2tlbkV4cCI6MTc0NDc3MDcxMCwiaWF0IjoxNzQ0NzY3MTEwLCJleHAiOjE3NDQ3NzA3MTB9.KbpvKZfJbahO9hZZgvugl_tYMyOAiKseSoS728K328Y"
        
        print("🔑 Using JWT token: \(jwtToken.prefix(20))...")
        authContext.jwtToken = jwtToken
        
        // Attempt authentication
        let authResult = authService.sdkAuth(authContext)

        print("📡 Auth result code: \(authResult.rawValue)")
        
        switch authResult {
        case ZoomSDKError_Success:
            print("✅ Auth request sent successfully, waiting for callback...")
        case ZoomSDKError_ServiceFailed:
            print("❌ Auth service failed - service might not be ready")
        case ZoomSDKError_InvalidParameter:
            print("❌ Invalid parameters provided for authentication")
        default:
            print("❌ Authentication request failed with code: \(authResult.rawValue)")
        }
        
        print("================================================")
    }

    func joinMeeting() {
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
            
            switch returnValue {
            case ZoomSDKAuthError_Success:
                print("✅ Authentication successful")
                self.joinMeeting()
            case ZoomSDKAuthError_KeyOrSecretWrong:
                print("❌ SDK key or secret is wrong")
            case ZoomSDKAuthError_AccountNotSupport:
                print("❌ Account does not support SDK")
            case ZoomSDKAuthError_AccountNotEnableSDK:
                print("❌ Account has not enabled SDK")
            case ZoomSDKAuthError_Unknown:
                print("❌ Unknown authentication error (100)")
                print("   You need to check the following:")
                print("   1. Your SDK app has the Meeting SDK enabled in the Zoom Marketplace")
                print("   2. Your JWT token is valid (not expired)")
                print("   3. Your meeting has the correct settings")
                print("   4. Network connectivity is working properly")
                print("   5. Your SDK version matches your Zoom account requirements")
            default:
                print("❌ Authentication failed with code: \(returnValue.rawValue)")
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
