import UIKit
import Flutter

// Push notifications (FCM): once Firebase is configured — add
// GoogleService-Info.plist to this target and `import Firebase` /
// `FirebaseApp.configure()` below — FirebaseAppDelegateProxyEnabled
// swizzling (add FirebaseAppDelegateProxyEnabled=NO and handle
// didRegisterForRemoteNotificationsWithDeviceToken if you prefer manual
// APNs wiring) delivers FCM tokens to the app's PushNotificationService.

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
