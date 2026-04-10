import UIKit
import Flutter
import WidgetKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let channelName = "com.example.language_toggle_widget/locale"
    private let appGroupID  = "group.com.example.languageToggleWidget"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "setLocale":
                // iOS doesn't allow programmatic system language change;
                // the Flutter MaterialApp locale parameter handles in-app locale.
                result(nil)

            case "resetLocale":
                result(nil)

            case "updateWidget":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                    return
                }
                self.persistAndRefreshWidget(args: args)
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Handle deep-link from widget tap.
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "langtoggle" && url.host == "toggle" {
            // Post a notification so Flutter can listen and react.
            NotificationCenter.default.post(name: NSNotification.Name("WidgetToggleTapped"), object: nil)
        }
        return true
    }

    // MARK: - Private

    private func persistAndRefreshWidget(args: [String: Any]) {
        let isEnabled   = args["isEnabled"]    as? Bool   ?? false
        let langName    = args["languageName"] as? String ?? "Native"
        let langFlag    = args["languageFlag"] as? String ?? "🏠"

        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(isEnabled, forKey: "flutter.is_enabled")
        defaults?.set(langName,  forKey: "flutter.current_language_name")
        defaults?.set(langFlag,  forKey: "flutter.current_language_flag")
        defaults?.synchronize()

        // Tell WidgetKit to reload the timeline.
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
