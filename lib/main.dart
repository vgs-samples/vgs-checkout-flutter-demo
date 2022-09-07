import 'package:flutter/material.dart';

import 'package:vgs_checkout_flutter_demo/presentation/pages/checkout_custom_config.dart';
import 'package:vgs_checkout_flutter_demo/presentation/pages/checkout_pay_opt.dart';
import 'package:vgs_checkout_flutter_demo/presentation/pages/checkout_use_cases.dart';
import './utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CheckoutUseCases(),
      routes: {
        RouteNames.kCustomConfig: (context) => const CheckoutCustomConfig(),
        RouteNames.kPayOptAddCardConfig: (context) =>
            const CheckoutPayoptAddCardConfig(),
      },
    );
  }
}
