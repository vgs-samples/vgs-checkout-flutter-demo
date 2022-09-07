import 'package:vgs_checkout_flutter_demo/models/order_model.dart';

class OrderDataProvider {
  List<OrderModel> provideOrders() {
    return [
      OrderModel(
        id: '1',
        title: 'Pizza diablo',
        imageName: 'assets/images/order_images/cropped_pizza_1.png',
        price: 9.0,
      ),
      OrderModel(
        id: '2',
        title: 'Pizza vegano',
        imageName: 'assets/images/order_images/cropped_pizza_2.png',
        price: 45.0,
      )
    ];
  }
}
