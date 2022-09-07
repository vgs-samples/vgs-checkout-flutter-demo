import 'package:flutter/material.dart';

class OrderTotalPrice extends StatelessWidget {
  final String price;
  const OrderTotalPrice({Key? key, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Total:',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            '${price}\$',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        )
      ],
    );
  }
}
