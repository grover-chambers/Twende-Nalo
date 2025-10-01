import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/delivery_task.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const CustomerOrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<CustomerOrderTrackingScreen> createState() => _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState extends State<CustomerOrderTrackingScreen> {
  late Stream<DocumentSnapshot> _deliveryTaskStream;
  // Removed _isLoading as it was not used

  @override
  void initState() {
    super.initState();
    _deliveryTaskStream = FirebaseFirestore.instance
        .collection('delivery_tasks')
        .where('orderId', isEqualTo: widget.orderId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Order'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _deliveryTaskStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyWidget();
          }

          final deliveryTask = DeliveryTask.fromJson(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return _buildTrackingContent(deliveryTask);
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load order details'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No delivery information found'),
          const SizedBox(height: 8),
          const Text('Your order may still be processing'),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(DeliveryTask deliveryTask) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildOrderHeader(deliveryTask),
            _buildTrackingTimeline(deliveryTask),
            _buildDeliveryDetails(deliveryTask),
            _buildOrderItems(deliveryTask),
            _buildContactSection(deliveryTask),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(DeliveryTask deliveryTask) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${deliveryTask.orderId.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(deliveryTask.status).withOpacity(0.2), // TODO: Replace with proper alpha handling when .withValues() is available
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  deliveryTask.statusDisplay,
                  style: TextStyle(
                    color: _getStatusColor(deliveryTask.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: KES ${deliveryTask.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Placed on ${_formatDate(deliveryTask.createdAt)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(DeliveryTask deliveryTask) {
    final steps = [
      {
        'title': 'Order Confirmed',
        'subtitle': 'Your order has been received',
        'time': deliveryTask.createdAt,
        'isCompleted': true,
      },
      {
        'title': 'Rider Assigned',
        'subtitle': 'A rider has been assigned to your order',
        'time': deliveryTask.acceptedAt,
        'isCompleted': deliveryTask.acceptedAt != null,
      },
      {
        'title': 'Order Picked Up',
        'subtitle': 'Your order is on the way',
        'time': deliveryTask.pickedUpAt,
        'isCompleted': deliveryTask.pickedUpAt != null,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Your order has been delivered',
        'time': deliveryTask.deliveredAt,
        'isCompleted': deliveryTask.deliveredAt != null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return _buildTimelineStep(
                  step['title'] as String,
                  step['subtitle'] as String,
                  step['time'] as DateTime?,
                  step['isCompleted'] as bool,
                  index == steps.length - 1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    DateTime? time,
    bool isCompleted,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 16,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (time != null)
                Text(
                  _formatDateTime(time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDetails(DeliveryTask deliveryTask) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.location_on,
                'Delivery Address',
                deliveryTask.deliveryAddress,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.person,
                'Customer',
                deliveryTask.customerName,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.phone,
                'Phone',
                deliveryTask.customerPhone,
              ),
              if (deliveryTask.estimatedDistance != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.directions_car,
                  'Distance',
                  '${deliveryTask.estimatedDistance!.toStringAsFixed(1)} km',
                ),
              ],
              if (deliveryTask.estimatedDuration != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.timer,
                  'Estimated Time',
                  '${deliveryTask.estimatedDuration!.toInt()} min',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(DeliveryTask deliveryTask) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...deliveryTask.items.map((item) => _buildOrderItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(DeliveryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shopping_bag),
                    ),
                  )
                : const Icon(Icons.shopping_bag),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.quantity} × KES ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'KES ${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(DeliveryTask deliveryTask) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement call functionality
                        _launchPhoneCall(deliveryTask.customerPhone);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Support'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement chat functionality
                        _openChat(deliveryTask.riderId);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'pickedUp':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _launchPhoneCall(String phoneNumber) {
    // Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openChat(String riderId) {
    // Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
