import 'package:flutter/material.dart';

import 'package:vgs_checkout_flutter_demo/models/order_model.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;

  const OrderItem({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              child: Image.asset(
                order.imageName,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              order.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                order.price.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
