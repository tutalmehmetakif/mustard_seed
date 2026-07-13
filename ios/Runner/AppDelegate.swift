import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // "Fotoğraflı" widget stili için: Flutter'dan gelen fotoğraf bayt
    // verisini App Group paylaşımlı container'ına yazan köprü.
    // Widget extension AYRI bir process'te çalıştığı için ana uygulamanın
    // Documents klasörüne erişemiyor — bu yüzden App Group container'ı
    // kullanmak zorunludur (bkz. WidgetService.saveUserPhoto).
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WidgetPhotoChannel")
    let photoChannel = FlutterMethodChannel(
      name: "com.hardaltanesi.app/widget_photo",
      binaryMessenger: registrar.messenger()
    )

    photoChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "savePhoto":
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData else {
          result(FlutterError(code: "BAD_ARGS", message: "bytes eksik", details: nil))
          return
        }
        let success = AppDelegate.saveToAppGroup(data: bytes.data)
        result(success)

      case "clearPhoto":
        let success = AppDelegate.clearFromAppGroup()
        result(success)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Flutter'dan gelen fotoğraf bayt verisini, widget extension'ın da
  /// erişebildiği App Group paylaşımlı container'ına sabit bir dosya
  /// adıyla yazar. Widget tarafı bu dosyayı VerseWidget.swift içindeki
  /// loadUserPhoto() ile okur.
  private static func saveToAppGroup(data: Data) -> Bool {
    guard let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.io.supabase.mustardseed"
    ) else { return false }

    let fileURL = containerURL.appendingPathComponent("widget_user_photo.jpg")
    do {
      try data.write(to: fileURL, options: .atomic)
      return true
    } catch {
      return false
    }
  }

  private static func clearFromAppGroup() -> Bool {
    guard let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.io.supabase.mustardseed"
    ) else { return false }

    let fileURL = containerURL.appendingPathComponent("widget_user_photo.jpg")
    do {
      if FileManager.default.fileExists(atPath: fileURL.path) {
        try FileManager.default.removeItem(at: fileURL)
      }
      return true
    } catch {
      return false
    }
  }
}