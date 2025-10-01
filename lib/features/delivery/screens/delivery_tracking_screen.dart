import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/delivery_task.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String deliveryId;
  final DeliveryTask? deliveryTask;

  const DeliveryTrackingScreen({
    Key? key,
    required this.deliveryId,
    this.deliveryTask,
  }) : super(key: key);

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  bool _isLoading = true;
  DeliveryTask? _deliveryTask;
  Duration _estimatedTime = const Duration(minutes: 25);
  DateTime _estimatedArrival = DateTime.now().add(const Duration(minutes: 25));

  // Delivery stages
  final List<DeliveryStage> _deliveryStages = [
    DeliveryStage(
      status: 'Order Confirmed',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Your order has been confirmed',
      isCompleted: true,
    ),
    DeliveryStage(
      status: 'Preparing Order',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      description: 'Shop is preparing your order',
      isCompleted: true,
    ),
    DeliveryStage(
      status: 'Out for Delivery',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      description: 'Rider has picked up your order',
      isCompleted: true,
    ),
    DeliveryStage(
      status: 'On the Way',
      time: DateTime.now(),
      description: 'Rider is on the way to your location',
      isCompleted: false,
    ),
    DeliveryStage(
      status: 'Delivered',
      time: null,
      description: 'Order delivered successfully',
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveryDetails();
  }

  void _loadDeliveryDetails() async {
    // Simulate loading delivery details
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _deliveryTask = widget.deliveryTask ?? DeliveryTask(
        id: widget.deliveryId,
        orderId: 'ORD-${widget.deliveryId.substring(0, 8).toUpperCase()}',
        customerId: 'user_123',
        riderId: 'rider_456',
        customerName: 'John Doe',
        customerPhone: '+254 712 345 678',
        deliveryAddress: '123 Main Street, Nairobi',
        pickupLocation: const GeoPoint(-1.2921, 36.8219),
        deliveryLocation: const GeoPoint(-1.2841, 36.8179),
        items: [
          DeliveryItem(
            id: 'item_1',
            name: 'Fresh Milk',
            quantity: 2,
            price: 120.0,
            imageUrl: 'assets/images/milk.jpg',
          ),
          DeliveryItem(
            id: 'item_2',
            name: 'Fresh Apples',
            quantity: 1,
            price: 200.0,
            imageUrl: 'assets/images/apples.jpg',
          ),
        ],
        totalAmount: 320.0,
        status: 'pickedUp',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        estimatedDuration: 25.0,
        estimatedDistance: 3.5,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with ETA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated arrival',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(_estimatedArrival),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'in ${_estimatedTime.inMinutes} minutes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delivery Timeline
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Timeline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryTimeline(),

                  const SizedBox(height: 20),

                  // Order Details
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderDetails(),

                  const SizedBox(height: 20),

                  // Rider Information
                  Text(
                    'Your Rider',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRiderCard(),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Implement call functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling rider...'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Rider'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement delivery confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Delivery confirmed!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirm Delivery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeline() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _deliveryStages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final stage = _deliveryStages[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stage.isCompleted ? Colors.green : Colors.grey,
              ),
              child: Icon(
                stage.isCompleted ? Icons.check : Icons.circle,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.status,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: stage.isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (stage.description != null)
                    Text(
                      stage.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (stage.time != null)
                    Text(
                      DateFormat('hh:mm a').format(stage.time!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiderCard() {
    if (_deliveryTask == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Michael Kamau',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '+254 723 456 789',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    if (_deliveryTask == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${_deliveryTask!.orderId}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._deliveryTask!.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${item.quantity} × KES ${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'KES ${(item.quantity * item.price).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KES ${_deliveryTask!.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryStage {
  final String status;
  final DateTime? time;
  final String? description;
  bool isCompleted;

  DeliveryStage({
    required this.status,
    this.time,
    this.description,
    required this.isCompleted,
  });
}
