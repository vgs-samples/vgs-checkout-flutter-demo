import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import '../../api/custom_backend_api_client.dart';
import '../widgets/order_summary_widget.dart';
import '../widgets/scrollable_text_widget.dart';
import '../../services/order_data_provider.dart';
import '../../utils/checkout_constants.dart';
import '../../utils//snackbar_utils.dart';

class CheckoutPayoptAddCardConfig extends StatefulWidget {
  const CheckoutPayoptAddCardConfig({Key? key}) : super(key: key);

  @override
  State<CheckoutPayoptAddCardConfig> createState() =>
      _CheckoutPayOptAddCardConfigState();
}

class _CheckoutPayOptAddCardConfigState
    extends State<CheckoutPayoptAddCardConfig> {
  // Method channel is used to invoce native code from Flutter and vice versa.
  static const platform = MethodChannel('vgs.com.checkout/payoptAddCardConfig');

  var _outputText = '';
  var _isLoading = false;
  final _customApiClient = CustomBackendApiClient();
  var _accessToken = '';

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
        print('Cancel');
        break;
      // Navigator.pushNamed(context, "/ring");
      case CheckoutMethodNames.handleCheckoutSuccess:
        if (arguments != null && arguments is Map<dynamic, dynamic>) {
          var eventData = new Map<String, dynamic>.from(arguments);
          if (eventData[CheckoutEventConstants.data]
              is Map<dynamic, dynamic>) {
            final data = eventData[CheckoutEventConstants.data]
                as Map<dynamic, dynamic>;
            final json = new Map<String, dynamic>.from(data);
            print('pay opt add card config json: ${json}');
          }

          if (eventData[CheckoutEventConstants.description] is String) {
            final description =
                eventData[CheckoutEventConstants.description] as String;
            textToDisplay = 'Checkout did finish successfully!\n$description';
          }

          toastMessageText = 'Succeffully added card.';
        }
        break;
      case CheckoutMethodNames.handleCheckoutFail:
        if (arguments != null && arguments is Map<dynamic, dynamic>) {
          var eventData = new Map<String, dynamic>.from(arguments);
          if (eventData[CheckoutEventConstants.data] is String) {
            final errorData = eventData[CheckoutEventConstants.data] as String;
          }
          if (eventData[CheckoutEventConstants.statusCode] is int) {
            final statusCode =
                eventData[CheckoutEventConstants.statusCode] as int;
          }
          if (eventData[CheckoutEventConstants.description] is String) {
            final eventDescription =
                eventData[CheckoutEventConstants.description] as String;
            textToDisplay = eventDescription;
          }

          toastMessageText = 'Failed to add card.';

          isError = true;
          break;
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

  Future<Map<dynamic, dynamic>?> _startCheckoutAddCardConfig() async {
      try {
        final checkoutResult = await platform
            .invokeMethod(CheckoutMethodNames.startAddCardCheckoutConfig, {
          'tenant_id': CheckoutSetupConstants.tenantId,
          'environment': CheckoutSetupConstants.environment,
          'access_token': _accessToken,
          'saved_fin_ids': ['FIN_ID_1', 'FIN_ID_2']
        });

        if (checkoutResult != null && checkoutResult is Map<dynamic, dynamic>) {
          var resultPayload = new Map<String, dynamic>.from(checkoutResult);

          var toastMessageText = '';
          var textToDisplay = '';
          final status = resultPayload['STATUS_START'] as String;
          switch (status) {
            case 'SUCCESS':
              textToDisplay = 'Checkout started successfully.';
              toastMessageText = 'Checkout started';
              print(textToDisplay + toastMessageText);
              break;
            case 'FAILURE':
              final errorText = resultPayload['ERROR'] as String;
              toastMessageText =
                  'Failed to start checkout with error ${errorText}).';
              textToDisplay = 'Checkout did failed\n${errorText}';

              SnackBarUtils.showErrorSnackBar(
                context,
                text: toastMessageText,
                isError: true,
              );
              break;
            default:
              break;
          }
        }
      } on PlatformException catch (e) {
        print('Platform exception: ${e.message}');
      }

      // Update UI.
      setState(() {});
  }

  void _fetchAccessToken() async {
    if (_accessToken.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      var failureOrToken = await _customApiClient.getAccessToken();
      failureOrToken.fold((error) {
        setState(() {
          _isLoading = false;
        });
        print('Error!');
        SnackBarUtils.showErrorSnackBar(
          context,
          text: 'Cannot fetch access token',
          isError: true,
        );
      }, (token) async {
        _accessToken = token;
        setState(() {
          _isLoading = false;
        });
        await _startCheckoutAddCardConfig();
      });
    } else {
      await _startCheckoutAddCardConfig();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay Opt Add Card Config',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            OrderSummary(
              orders: OrderDataProvider().provideOrders(),
            ),
            const SizedBox(
              height: 16,
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        _fetchAccessToken();
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
