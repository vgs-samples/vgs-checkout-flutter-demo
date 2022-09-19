//
//  PayOptAddCardConfigChannel.swift
//  Runner
//

import Foundation
import UIKit
import Flutter
import VGSCheckoutSDK

/// Implementation of Flutter Bridge (FlutterMethodChannel).
class PayOptAddCardConfigChannel: NSObject {

	// MARK: - Initialization.

	/// Initializer.
	/// - Parameter messenger: `FlutterBinaryMessenger` object, binary messenger,
	init(messenger: FlutterBinaryMessenger) {
		// Create Flutter method channel to invoce methods from Flutter code in native iOS code by sending messages.
		flutterMethodChannel = FlutterMethodChannel(name: "vgs.com.checkout/payoptAddCardConfig",
																							binaryMessenger: messenger)
		super.init()
		registerConfigChannel()
	}

	// MARK: - Vars

	/// Checkout instance.
	fileprivate var vgsCheckout: VGSCheckout?

	/// Flutter method channel.
	fileprivate var flutterMethodChannel: FlutterMethodChannel

	// MARK: - Method Channel

	/// Registers pay opt config channel.
	func registerConfigChannel() {
		// Set handler to invoce native iOS code on messages from Flutter code.
		flutterMethodChannel.setMethodCallHandler({[weak self]
			(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			// This method is invoked on the UI thread.
			guard call.method == "startCheckoutAddCardConfig" else {
				result(FlutterMethodNotImplemented)
				return
			}
			guard let payload = call.arguments as? [String:Any],
						let token = payload["access_token"] as? String,
      let tenantId = payload["tenant_id"] as? String,
         let environment = payload["environment"] as? String else {
        assertionFailure("Invalid config")
        return
			}

			var savedIds: [String]  = []
			if let ids = payload["saved_fin_ids"] as? [String]          {
				savedIds = ids
			}

			print("access_token: \(token)")
			print("savedIds: \(savedIds)")
			self?.startAddCardConfiguration(with: token, tenantID: tenantId, environment: environment, savedCardIds: savedIds, result: result)
		})
	}

  private func startAddCardConfiguration(with accessToken: String, tenantID: String, environment: String, savedCardIds: [String], result: @escaping FlutterResult) {

		// Create payment options.
		var options = VGSCheckoutPaymentOptions()
		// Add array of saved cards:
		options.methods = .savedCards(savedCardIds)

		VGSCheckoutAddCardConfiguration.createConfiguration(accessToken: accessToken, tenantId: tenantID, environment: environment, options: options) {[weak self] configuration in
			guard let strongSelf = self else {return}
			configuration.billingAddressVisibility = .visible


//			configuration.billingAddressCountryFieldOptions.visibility = .hidden
//			configuration.billingAddressLine1FieldOptions.visibility = .hidden
//			configuration.billingAddressCountryFieldOptions.validCountries = ["US"]
//			configuration.billingAddressLine2FieldOptions.visibility = .hidden
//			configuration.billingAddressCityFieldOptions.visibility = .hidden
//			configuration.billingAddressPostalCodeFieldOptions.visibility = .visible

			let controller : FlutterViewController = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController

			strongSelf.vgsCheckout = VGSCheckout(configuration: configuration)
			strongSelf.vgsCheckout?.delegate = strongSelf
			// Present checkout configuration.
			strongSelf.vgsCheckout?.present(from: controller)

			// Call result object after presenting checkout with 0.3s delay.
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				var payload: [String: Any] = [:]
				payload["STATUS_START"] = "SUCCESS"
				result(payload)
			}
		} failure: {[weak self] error in
			var payload: [String: Any] = [:]
			payload["STATUS_START"] = "FAILURE"
			payload["STATUS_ERROR"] = error.localizedDescription

			// Call result with error payload to notify Flutter code about error.
			result(payload)
		}
	}
}

// MARK: - VGSCheckoutDelegate

extension PayOptAddCardConfigChannel: VGSCheckoutDelegate {
	func checkoutDidCancel() {
		flutterMethodChannel.invokeMethod("handleCancelCheckout", arguments: nil)
	}

	func checkoutDidFinish(with paymentMethod: VGSCheckoutPaymentMethod) {

		switch paymentMethod {
		case .savedCard(let savedCardInfo):

			var payload: [String: Any] = [:]
			payload["STATUS"] = "FINISHED_SUCCESS"
			payload["PAYMENT_METHOD"] = "SAVED_CARD"
			payload["DATA"] = savedCardInfo.id
			payload["DESCRIPTION"] = "User selected already saved card."

			self.flutterMethodChannel.invokeMethod("handleCheckoutSuccess", arguments: payload)
		case .newCard(let requestResult, let newCardInfo):

			switch requestResult {
			case .success(let statusCode, let data, let response, let info):
				let text = DemoAppResponseParser.stringifySuccessResponse(from: data, rootJsonKey: "data") ?? ""

				var payload: [String: Any] = [:]
				payload["STATUS"] = "FINISHED_SUCCESS"
				payload["PAYMENT_METHOD"] = "NEW_CARD"
				payload["SHOULD_SAVE_CARD"] = newCardInfo.shouldSave
				payload["DESCRIPTION"] = text
				payload["DATA"] = DemoAppResponseParser.convertToJSON(from: data)

				self.flutterMethodChannel.invokeMethod("handleCheckoutSuccess", arguments: payload)
			case .failure(let statusCode, let data, _, let error, let info):
				let text = "status code is: \(statusCode) error: \(error?.localizedDescription ?? "Uknown error!")"

				var payload: [String: Any] = [:]
				payload["STATUS"] = "FINISHED_ERROR"
				payload["STATUS_CODE"] = statusCode
				payload["PAYMENT_METHOD"] = "NEW_CARD"
				payload["SHOULD_SAVE_CARD"] = newCardInfo.shouldSave
				payload["DESCRIPTION"] = text
				if let cardData = data {
					payload["DATA"] = String(decoding: cardData, as: UTF8.self)
				}

				self.flutterMethodChannel.invokeMethod("handleCheckoutFail", arguments: payload)
			}
		}
	}

	func removeCardDidFinish(with id: String, result: VGSCheckoutRequestResult) {
		switch result {
		case .success(let _, let _, let _, let _):
			print("Remove card with fin_instrument_id \(id) succeeded!")
		case .failure(let _, let _, let _, let _, let _):
			print("Remove card with fin_instrument_id \(id) failed!")
		}
	}
}
