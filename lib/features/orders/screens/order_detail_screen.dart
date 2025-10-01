import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart' as order_model;
import '../widgets/order_card.dart';
import '../../notifications/providers/notification_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  late order_model.Order _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await orderProvider.loadOrderById(widget.orderId);
      final orders = orderProvider.orders;
      final order = orders.firstWhere((o) => o.id == widget.orderId);
      
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusIndicator(order_model.OrderStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.transparent, 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _order.statusDisplayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return Colors.orange;
      case order_model.OrderStatus.confirmed:
        return Colors.blue;
      case order_model.OrderStatus.preparing:
        return Colors.purple;
      case order_model.OrderStatus.readyForPickup:
        return Colors.indigo;
      case order_model.OrderStatus.pickedUp:
        return Colors.teal;
      case order_model.OrderStatus.inTransit:
        return Colors.cyan;
      case order_model.OrderStatus.delivered:
        return Colors.green;
      case order_model.OrderStatus.cancelled:
        return Colors.red;
      case order_model.OrderStatus.refunded:
        return Colors.grey;
    }
  }

  Widget _buildOrderTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Timeline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.shopping_cart,
          title: 'Order Placed',
          subtitle: DateFormat('MMM dd, yyyy • hh:mm a').format(_order.createdAt),
          isActive: true,
        ),
        if (_order.status.index >= order_model.OrderStatus.confirmed.index)
          _buildTimelineItem(
            icon: Icons.check_circle,
            title: 'Order Confirmed',
            subtitle: 'Shop has confirmed your order',
            isActive: true,
          ),
        if (_order.status.index >= order_model.OrderStatus.preparing.index)
          _buildTimelineItem(
            icon: Icons.restaurant,
            title: 'Preparing Order',
            subtitle: 'Shop is preparing your items',
            isActive: true,
          ),
        if (_order.status.index >= order_model.OrderStatus.readyForPickup.index)
          _buildTimelineItem(
            icon: Icons.local_shipping,
            title: 'Ready for Pickup',
            subtitle: 'Order is ready for rider pickup',
            isActive: true,
          ),
        if (_order.status.index >= order_model.OrderStatus.pickedUp.index)
          _buildTimelineItem(
            icon: Icons.person_pin_circle,
            title: 'Picked Up',
            subtitle: 'Rider has picked up your order',
            isActive: true,
          ),
        if (_order.status.index >= order_model.OrderStatus.inTransit.index)
          _buildTimelineItem(
            icon: Icons.directions_bike,
            title: 'In Transit',
            subtitle: 'Order is on its way to you',
            isActive: true,
          ),
        if (_order.status.index >= order_model.OrderStatus.delivered.index)
          _buildTimelineItem(
            icon: Icons.verified,
            title: 'Delivered',
            subtitle: 'Order has been delivered',
            isActive: true,
          ),
        if (_order.status == order_model.OrderStatus.cancelled)
          _buildTimelineItem(
            icon: Icons.cancel,
            title: 'Order Cancelled',
            subtitle: 'Order has been cancelled',
            isActive: true,
          ),
        if (_order.status == order_model.OrderStatus.refunded)
          _buildTimelineItem(
            icon: Icons.money_off,
            title: 'Refunded',
            subtitle: 'Order has been refunded',
            isActive: true,
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blue : Colors.grey[300],
            ),
            child: Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._order.items.map((item) => ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: item.productImageUrl != null
                    ? Image.network(item.productImageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.fastfood, color: Colors.grey[400]),
              ),
              title: Text(item.displayName),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text(item.formattedUnitPrice),
            )),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Subtotal', _order.formattedSubtotal),
            _buildSummaryRow('Delivery Fee', _order.formattedDeliveryFee),
            _buildSummaryRow('Tax', _order.formattedTax),
            const Divider(),
            _buildSummaryRow(
              'Total',
              _order.formattedTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrder,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${_order.id.substring(0, 8)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _buildStatusIndicator(_order.status),
              ],
            ),
            const SizedBox(height: 16),

            // Order Timeline
            _buildOrderTimeline(),
            const SizedBox(height: 24),

            // Order Items
            _buildOrderItems(),
            const SizedBox(height: 24),

            // Order Summary
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }
}
