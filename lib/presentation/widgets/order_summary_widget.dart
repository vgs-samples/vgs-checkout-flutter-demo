import 'package:flutter/material.dart';

import 'package:vgs_checkout_flutter_demo/models/order_model.dart';
import 'package:vgs_checkout_flutter_demo/presentation/widgets/order_item_widget.dart';
import 'package:vgs_checkout_flutter_demo/presentation/widgets/order_total_price_widget.dart';

class OrderSummary extends StatelessWidget {
  final List<OrderModel> orders;
  const OrderSummary({
    Key? key,
    required this.orders,
  }) : super(key: key);

  String _orderPriceText() {
    final prices = orders.map((order) => order.price);
    final sum = prices.reduce((value, element) => value + element);
    return sum.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        'Your order',
        style: TextStyle(
          color: Colors.black,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      ListView.builder(
          itemBuilder: (context, index) {
            return OrderItem(order: orders[index]);
          },
          shrinkWrap: true,
          itemCount: orders.length),
      const SizedBox(
        height: 8,
      ),
      const Divider(
        thickness: 1,
        color: Colors.black,
      ),
      const SizedBox(
        height: 8,
      ),
      OrderTotalPrice(
        price: _orderPriceText(),
      )
    ]);
  }
}
