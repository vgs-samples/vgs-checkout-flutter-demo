class CheckoutEventConstants {
  static const String status = 'STATUS';
  static const String finishedSuccess = 'FINISHED_SUCCESS';
  static const String finishedError = 'FINISHED_ERROR';
  static const String statusCode = 'STATUS_CODE';
  static const String paymentMethod = 'PAYMENT_METHOD';
  static const String shouldSaveCard = 'SHOULD_SAVE_CARD';
  static const String data = 'DATA';
  static const String description = 'DESCRIPTION';
  static const String cancelled = 'CANCELLED';
}

class CheckoutMethodNames {
  static const String handleCancelCheckout = 'handleCancelCheckout';
  static const String handleCheckoutSuccess = 'handleCheckoutSuccess';
  static const String handleCheckoutFail = 'handleCheckoutFail';
  static const String startCustomCheckoutConfig = 'startCustomCheckoutConfig';
  static const String startAddCardCheckoutConfig = 'startCheckoutAddCardConfig';
}

class CheckoutSetupConstants {
  static const String vaultId = 'vault_id'; // For custom config
  static const String tenantId = 'tenant_id'; // For payopt config
  static const String environment = 'environment';
}
