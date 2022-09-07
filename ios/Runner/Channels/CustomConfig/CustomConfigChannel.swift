//
//  CustomConfigChannel.swift
//  Runner
//

import Foundation
import UIKit
import Flutter
import VGSCheckoutSDK

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

	/// Start custom checkout configuration.
	/// - Parameter result: `FlutterResult` object, flutter result.
	private func startCustomCheckoutConfig(result: @escaping FlutterResult) {

		// Use root view controller (acts like a main app widget) to present checkout from.
		let controller : FlutterViewController = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController

		var checkoutConfiguration = VGSCheckoutCustomConfiguration(vaultID: DemoAppConfiguration.shared.vaultId, environment: DemoAppConfiguration.shared.environment)

		checkoutConfiguration.cardHolderFieldOptions.fieldNameType = .single("cardHolder_name")
		checkoutConfiguration.cardNumberFieldOptions.fieldName = "card_number"
		checkoutConfiguration.expirationDateFieldOptions.fieldName = "exp_data"
		checkoutConfiguration.cvcFieldOptions.fieldName = "card_cvc"

		checkoutConfiguration.billingAddressVisibility = .visible

		checkoutConfiguration.billingAddressCountryFieldOptions.fieldName = "billing_address.country"
		checkoutConfiguration.billingAddressCityFieldOptions.fieldName = "billing_address.city"
		checkoutConfiguration.billingAddressLine1FieldOptions.fieldName = "billing_address.addressLine1"
		checkoutConfiguration.billingAddressLine2FieldOptions.fieldName = "billing_address.addressLine2"
		checkoutConfiguration.billingAddressPostalCodeFieldOptions.fieldName = "billing_address.postal_code"

		// Produce nested json for fields with `.` notation.
		checkoutConfiguration.routeConfiguration.requestOptions.mergePolicy = .nestedJSON

		checkoutConfiguration.routeConfiguration.path = "post"

		/* Set custom date user input/output JSON format.

		checkoutConfiguration.expirationDateFieldOptions.inputDateFormat = .shortYearThenMonth
		checkoutConfiguration.expirationDateFieldOptions.outputDateFormat = .longYearThenMonth

		let expDateSerializer = VGSCheckoutExpDateSeparateSerializer(monthFieldName: "card_date.month", yearFieldName: "card_date.year")
		checkoutConfiguration.expirationDateFieldOptions.serializers = [expDateSerializer]
		*/

		// Init Checkout with vault and ID.
		vgsCheckout = VGSCheckout(configuration: checkoutConfiguration)

		//VGSPaymentCards.visa.formatPattern = "#### #### #### ####"

		/// Change default valid card number lengthes
//		VGSPaymentCards.visa.cardNumberLengths = [16]
//		/// Change default format pattern
//		VGSPaymentCards.visa.formatPattern = "#### #### #### ####"

		// Listen to events from Checkout in native iOS code.
		// Delegate is native iOS pattern which implies emitter and single subscriber linked by each other with weak reference semantic.
		vgsCheckout?.delegate = self

		// Present checkout configuration.
		vgsCheckout?.present(from: controller)

		// Call result object after presenting checkout with 0.3s delay.
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			result(nil)
		}
	}
}

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
