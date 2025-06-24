import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/notification_service.dart';
import '../models/order_status.dart';
import '../provider/notification_provider.dart';
import '../provider/order_status_provider.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleStatusChange(BuildContext context, OrderStatus newStatus) {
    final provider = context.read<OrderStatusProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final oldStatus = provider.currentStatus;

    provider.updateStatus(newStatus);

    final title = "Order Status Update";
    final body = "Your order changed from ${oldStatus.name.capitalize()} to ${newStatus.name.capitalize()}";

    // Send local notification
    NotificationService.showStatusNotification(
      oldStatus: oldStatus.name.capitalize(),
      newStatus: newStatus.name.capitalize(),
    );

    // Add notification to provider (for badge and list)
    notificationProvider.addNotification(title, body);
  }

  @override
  Widget build(BuildContext context) {
    final orderStatus = context.watch<OrderStatusProvider>().currentStatus;
    final notifier = context.watch<NotificationProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5FA8D3), Color(0xFFE0E7FF)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            "iSupply Home",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                  context.read<NotificationProvider>().resetCount(); // clear counter
                },
              ),
              if (notifier.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text(
                      '${notifier.unreadCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1452A5), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: screenHeight * 0.15,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlassBox(
                height: screenHeight * 0.4,
                child: Column(
                  children: [
                    const Text(
                      "Track Your Order:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatusButton(context, OrderStatus.pending),
                    _buildStatusButton(context, OrderStatus.confirmed),
                    _buildStatusButton(context, OrderStatus.shipped),
                    _buildStatusButton(context, OrderStatus.delivered),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildGlassBox(
                height: screenHeight * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tracking Progress:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildProgressTracker(orderStatus),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, OrderStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(45),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0x805FA8D3),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.notifications_active_outlined),
        label: Text("Mark as ${status.name.capitalize()}"),
        onPressed: () => _handleStatusChange(context, status),
      ),
    );
  }

  Widget _buildProgressTracker(OrderStatus status) {
    final steps = OrderStatus.values;
    final currentIndex = steps.indexOf(status);

    final icons = {
      OrderStatus.pending: Icons.access_time,
      OrderStatus.confirmed: Icons.verified,
      OrderStatus.shipped: Icons.local_shipping,
      OrderStatus.delivered: Icons.check_circle,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.map((step) {
        final index = steps.indexOf(step);
        final isCompleted = index <= currentIndex;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 70,
              height: 8,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? const LinearGradient(
                  colors: [Color(0xFF5FA8D3), Color(0xFF1452A5)],
                )
                    : null,
                color: isCompleted ? null : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              icons[step],
              color: isCompleted ? const Color(0xFF1452A5) : Colors.black38,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              step.name.capitalize(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isCompleted ? const Color(0xFF1452A5) : Colors.black38,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGlassBox({
    required Widget child,
    required double height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

extension CapExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
