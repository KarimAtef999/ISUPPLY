import 'package:flutter/material.dart';

import '../models/order_status.dart';

class OrderStatusProvider extends ChangeNotifier {
  OrderStatus _currentStatus = OrderStatus.pending;

  OrderStatus get currentStatus => _currentStatus;

  void updateStatus(OrderStatus newStatus) {
    _currentStatus = newStatus;
    notifyListeners();
  }
}
