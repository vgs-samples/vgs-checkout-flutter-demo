import 'package:flutter/material.dart';

import 'package:vgs_checkout_flutter_demo/presentation/widgets/checkout_use_case_item_widget.dart';
import '../../utils/constants.dart';

class CheckoutUseCases extends StatelessWidget {
  const CheckoutUseCases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.kCustomConfig);
              },
              child: CheckoutUseCaseItem(
                title: 'Checkout Custom Config',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.kPayOptAddCardConfig);
              },
              child: CheckoutUseCaseItem(
                title: 'Checkout PayOpt Add Card Config',
              ),
            )
          ],
        ),
      ),
    );
  }
}
