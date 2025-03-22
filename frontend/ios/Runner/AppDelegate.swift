import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Add your Google Maps API key here
    GMSServices.provideAPIKey("AIzaSyAAf1Go7Q8vnwyRDoHxAOfqqcgZTlqZ4To")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}