import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

	// Checkout custom config channel.
	var checkoutCustomConfigChannel: CustomConfigChannel?

	// Checkout pay opt add card config channel.
	var checkoutPayoptAddCardConfigChannel: PayOptAddCardConfigChannel?

	//no:doc
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

		// Get current root view controller (`root` widget) to present Checkout.
		let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    // Register custom config method channel.
		checkoutCustomConfigChannel = CustomConfigChannel(messenger: controller.binaryMessenger)

		// Register payopt add card config method channel.
		checkoutPayoptAddCardConfigChannel = PayOptAddCardConfigChannel(messenger: controller.binaryMessenger)

		GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
