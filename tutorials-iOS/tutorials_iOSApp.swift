import SwiftUI //追加
import Firebase //追加
// ここから
class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
}
// ここまで追加

@main
struct tutorials_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // 追加
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
