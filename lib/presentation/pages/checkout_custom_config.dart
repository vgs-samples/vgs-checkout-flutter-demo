import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import '../widgets/order_summary_widget.dart';
import '../widgets/scrollable_text_widget.dart';
import '../../services/order_data_provider.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/checkout_event_constants.dart';

class CheckoutCustomConfig extends StatefulWidget {
  const CheckoutCustomConfig({Key? key}) : super(key: key);

  @override
  State<CheckoutCustomConfig> createState() => _CheckoutCustomConfigState();
}

class _CheckoutCustomConfigState extends State<CheckoutCustomConfig> {
  // Method channel is used to invoce native code from Flutter and vice versa.
  static const platform = MethodChannel('vgs.com.checkout/customConfig');

  var _outputText = '';

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

  Future<void> _startCheckoutCustomConfig() async {
    if (Platform.isAndroid) {
      // TODO:
      // Add Android implementation.
    } else if (Platform.isIOS) {
      try {
        final checkoutResult = await platform
            .invokeMethod(CheckoutMethodNames.startCustomCheckoutConfig);

        print('present checkout with custon config');
      } on PlatformException catch (e) {
        print('Platform exception: ${e.message}');
      }

      setState(() {
        // Update UI..
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Custom Config',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            OrderSummary(
              orders: OrderDataProvider().provideOrders(),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _startCheckoutCustomConfig();
                },
                child: const Text(
                  'ADD CARD',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ScrollableText(
                text: _outputText,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
