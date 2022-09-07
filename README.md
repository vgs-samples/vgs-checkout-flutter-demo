# README

This demo shows how to integrate VGS Checkout [iOS](https://github.com/verygoodsecurity/vgs-checkout-ios) and [Android](https://github.com/verygoodsecurity/vgs-checkout-android) SDK to your Flutter app. We don't have official Flutter package. You can easily integrate VGS Checkout SDK into your mobile crossplatform Flutter apps.

## Run application.

1. Required environment:

### Requirements

- Installed <a href="https://flutter.dev/docs/get-started/install" target="_blank">Flutter</a>
- Setup <a href="https://flutter.dev/docs/get-started/editor?tab=androidstudio" target="_blank">IDEA</a>
- Setup <a href="https://flutter.dev/docs/get-started/install/macos#install-xcode" target="_blank">Xcode</a>
- Install <a href="https://cocoapods.org/" target="_blank">Cocoapods</a> for running iOS
- Create your Organization with <a href="https://www.verygoodsecurity.com/">VGS</a>

> **_NOTE:_** Please visit Flutter <a href="https://flutter.dev/docs" target="_blank">documentation</a>
> for more detailed explanation how to setup Flutter and IDEA.</br>
> This sample is compatitable with Flutter 3.0.5 version.</br>
> Check Flutter issues <a href="https://github.com/flutter/flutter/issues" target="_blank">here.</a>

2. `cd` to `ios` folder and run

```bash
  pod install
```

3. `cd` to `ios/Runner/Models/DemoAppConfiguration` and find
   `DemoAppConfiguration.swift` file. Set your `vault_id` for custom configuation, `environment`, `tenant_id` for payment orchestration add card setup.

```swift
/// Setup your configuration details here.
class DemoAppConfiguration {

	/// Shared instance.
	static let shared = DemoAppConfiguration()

	/// no:doc
	private init() {}

	/// Set your vault id here. https://www.verygoodsecurity.com/terminology/nomenclature#vault
	var vaultId = "VAULT_ID"

	/// Set tenant id matching your payment orchestration configuration.
	var paymentOrchestrationTenantId = "TENANT_ID"

	/// Set environment - `sandbox` for testing or `live` for production.
	var environment = "sandbox"
}
```

4. go back to root project folder and `cd` to `lib/utils/constants`. Find `constants.dart` file and setup your custom backend api client if you need to test Payment integration.

```dart
class AppConstants {
  static const paymentOrchestrationServicePath =
      'https://custom-backend.com/';
}
```

5. run flutter app on iOS simulator

Run the iOS application on Simulator (<a href="https://flutter.dev/docs/get-started/install/macos#set-up-the-ios-simulator" target="_blank">Run iOS app Flutter docs</a>).

6. in case of possible issues a common fix is to clean project and reinstall packages:

```bash
  flutter clean
  flutter pub get
```

<p align="center">
	<img src="https://github.com/vgs-samples/vgs-checkout-flutter-demo/blob/main/images/VGSCheckout_Flutter_iOS.gif?raw=true" width="200" alt="VGS Checkout iOS Flutter demo">
</p>

## Integrate VGS Checkout SDK native iOS code with Flutter app

General integration overview:

<p align="center">
	<img src="https://github.com/vgs-samples/vgs-checkout-flutter-demo/blob/main/images/checkout_flutter_ios_integration.png" alt="VGS Checkout iOS Flutter integration diagram">
</p>

1. Review offical Flutter [documentation](https://docs.flutter.dev/development/platform-integration/platform-channels) how to integrate native and Flutter code.

2. Install `VGS Checkout SDK` via `CocoaPods`. If you have created from scratch Flutter project usually you need to preinstall `CocoaPods`.
   `cd` to `ios` folder and run:

```bash
  pod init
```

You should have `Podfile` in your `ios` directory. `Podfile` in iOS acts as a `pubspec.yaml` in Flutter and contains list of external dependencies. Add `VGSCheckoutSDK` pod to `Runner` `target`.

```bash
target 'Runner' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Runner

  pod 'VGSCheckoutSDK'
end
```

Make sure deployment minimal iOS version of your target and project
is set to `iOS 10` or later in iOS [project settings](https://stackoverflow.com/a/61335546).

Run:

```bash
  pod update
```

3. Implement method channels and handlers to invoke native iOS code
   from Flutter by sending messages.
   The Method Channel stems from binary messaging and the platform channel and supports a bidirectional invocation of methods.

   To keep `AppDelegate` sample lean all code with method channel setup is located in `ios\Runner\Channels` folders. Please check `CustomConfigChannel.swift` and `PayOptAddCardConfigChannel.swift` files.

```swift
 /// Implementation of Flutter Bridge (FlutterMethodChannel).
class CustomConfigChannel: NSObject {

	// MARK: - Initialization.

	/// Initializer.
	/// - Parameter messenger: `FlutterBinaryMessenger` object, binary messenger,
	init(messenger: FlutterBinaryMessenger) {
		// Create Flutter method channel to invoce methods from Flutter code in native iOS code by sending messages.
		flutterMethodChannel = FlutterMethodChannel(name: "vgs.com.checkout/customConfig",
																							binaryMessenger: messenger)
		super.init()
		registerCustomConfigChannel()
	}

	// MARK: - Vars

	/// Checkout instance.
	fileprivate var vgsCheckout: VGSCheckout?

	/// Flutter method channel.
	fileprivate var flutterMethodChannel: FlutterMethodChannel

	// MARK: - Method Channel

	/// Registers custom config channel.
	/// - Parameter controller: `FlutterViewController` object, Flutter view controller.
	func registerCustomConfigChannel() {

		// Set handler to invoce native iOS code on messages from Flutter code.
		flutterMethodChannel.setMethodCallHandler({[weak self]
			(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			// This method is invoked on the UI thread.
			guard call.method == "startCustomCheckoutConfig" else {
				result(FlutterMethodNotImplemented)
				return
			}

			self?.startCustomCheckoutConfig(result: result)
		})
	}
}
```

Note: it is important to call `FlutterResult` callback in `iOS` code. In this way you can notify `Flutter` app that Checkout started and you can `await` for the start event.

4. Implement `Flutter` code to start `VGS Checkout` from iOS code.

```dart
  // Create platform method channel.
  static const platform = MethodChannel('vgs.com.checkout/customConfig');

  // On button tap send `startCustomCheckoutConfig` message to native iOS code.
  Future<void> _startCheckoutCustomConfig() async {
    try {
      final checkoutResult =
          await platform.invokeMethod('startCustomCheckoutConfig');
      print('present checkout with custon config');
    } on PlatformException catch (e) {
      print('Platform exception: ${e.message}');
    }

    setState(() {
      // Update UI..
    });
  }
```

5. Implement `VGSCheckoutDelegate` inteface in your native channel implementation. VGS Checkout cannot emit events to Flutter code directly. It provides `VGSCheckoutDelegate` with a set of methods. t A delegate is just a class that does some work for another class and instances are usually linked by weak reference.
   You need to listen to `VGSCheckoutDelegate` methods and invoce methods in Flutter code using `invokeMethod`.
   It is up to you how to send and parse arguments payload.
   A suitable data structure can be Swift dictionary of type `[String: Any]` which will be transmitted as `Map<dynamic, dynamic>` in Flutter code.

```swift
// MARK: - VGSCheckoutDelegate

extension CustomConfigChannel: VGSCheckoutDelegate {
	func checkoutDidCancel() {
		flutterMethodChannel.invokeMethod("handleCancelCheckout", arguments: nil)
	}

	func checkoutDidFinish(with requestResult: VGSCheckoutRequestResult) {

		var title = ""
		var message = ""

		switch requestResult {
		case .success(let statusCode, let data, let response, let info):
			title = "Checkout status: Success!"
			message = "status code is: \(statusCode)"
			let text = DemoAppResponseParser.stringifySuccessResponse(from: data) ?? ""

			var payload = [String: Any]()
			payload["STATUS"] = "FINISHED_SUCCESS"
			payload["DESCRIPTION"] = text
			payload["DATA"] = DemoAppResponseParser.convertToJSON(from: data)

			flutterMethodChannel.invokeMethod("handleCheckoutSuccess", arguments: payload)
		case .failure(let statusCode, let data, let response, let error, let info):
			title = "Checkout status: Failed!"
			message = "status code is: \(statusCode) error: \(error?.localizedDescription ?? "Uknown error!")"

			var payload = [String: Any]()
			payload["STATUS"] = "FINISHED_ERROR"
			payload["DATA"] = message
			flutterMethodChannel.invokeMethod("handleCheckoutFail", arguments: payload)
		}
	}
}
```

6. Register Method and Event Channels in your `AppDelegate`.
   `AppDelegate` acts as an entry point in iOS native applications.

```swift
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

```

7. Handle methods invocation from native code in your Flutter code using `setMethodCallHandler`.

```dart
@override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(invokedMethods);
  }

  Future<dynamic> invokedMethods(MethodCall methodCall) async {
    var toastMessageText = '';
    var textToDisplay = '';
    var isError = false;
    final arguments = methodCall.arguments;
    switch (methodCall.method) {
      case CheckoutMethodNames.handleCancelCheckout:
        textToDisplay = 'User did cancel checkout.';
        toastMessageText = 'Checkout was cancelled.';
        break;
      // Navigator.pushNamed(context, "/ring");
      case CheckoutMethodNames.handleCheckoutSuccess:
        if (arguments != null && arguments is Map<dynamic, dynamic>) {
          var eventData = new Map<String, dynamic>.from(arguments);
          if (eventData[CheckoutEventConstants.kData]
              is Map<dynamic, dynamic>) {
            final data = eventData[CheckoutEventConstants.kData]
                as Map<dynamic, dynamic>;
            final json = new Map<String, dynamic>.from(data);
            print('custom config json: ${json}');
          }

          if (eventData[CheckoutEventConstants.kDescription] is String) {
            final description =
                eventData[CheckoutEventConstants.kDescription] as String;
            textToDisplay = 'Checkout did finish successfully!\n$description';
          }

          toastMessageText = 'Succeffully added card.';
        }
        break;
      case CheckoutMethodNames.handleCheckoutFail:
        if (arguments != null && arguments is Map<dynamic, dynamic>) {
          var eventData = new Map<String, dynamic>.from(arguments);
          if (arguments[CheckoutEventConstants.kData] is String) {
            final errorText = eventData[CheckoutEventConstants.kData] as String;
            textToDisplay = 'Checkout did failed\n$errorText';
          }
        }

        toastMessageText = 'Failed to add card.';
        break;
      default:
        break;
    }

    setState(() {
      _outputText = textToDisplay;
    });

    SnackBarUtils.showErrorSnackBar(
      context,
      text: toastMessageText,
      isError: isError,
    );
  }

```

8. Checkout will be presented as a separate screen like fullscreen modal `Widget` with its own `Scaffold` and `AppBar` presented by iOS `UINavigationController` as native iOS UI control. You cannot add your own widgets on the Checkout page.
