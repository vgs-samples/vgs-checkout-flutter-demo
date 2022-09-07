class CheckoutEventConstants {
  static const String kStatus = 'STATUS';
  static const String kFinishedSuccess = 'FINISHED_SUCCESS';
  static const String kFinishedError = 'FINISHED_ERROR';
  static const String kStatusCode = 'STATUS_CODE';
  static const String kPaymentMethod = 'PAYMENT_METHOD';
  static const String kShouldSaveCard = 'SHOULD_SAVE_CARD';
  static const String kData = 'DATA';
  static const String kDescription = 'DESCRIPTION';
  static const String kCancelled = 'CANCELLED';
}

class CheckoutMethodNames {
  static const String handleCancelCheckout = 'handleCancelCheckout';
  static const String handleCheckoutSuccess = 'handleCheckoutSuccess';
  static const String handleCheckoutFail = 'handleCheckoutFail';
  static const String startCustomCheckoutConfig = 'startCustomCheckoutConfig';
  static const String startAddCardCheckoutConfig = 'startCheckoutAddCardConfig';
}
