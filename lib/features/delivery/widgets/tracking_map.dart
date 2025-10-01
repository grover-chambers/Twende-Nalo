import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_task.dart';

class TrackingMap extends StatefulWidget {
  final DeliveryTask deliveryTask;
  final bool isRiderView;
  final Function(GeoPoint)? onLocationUpdate;

  const TrackingMap({
    Key? key,
    required this.deliveryTask,
    this.isRiderView = false,
    this.onLocationUpdate,
  }) : super(key: key);

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  StreamSubscription? _locationSubscription;
  GeoPoint? _riderLocation;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);
    
    if (widget.isRiderView) {
      _startLocationSimulation();
    } else {
      _loadRiderLocation();
    }
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _startLocationSimulation() {
    // Simulate rider movement from pickup to delivery
    final pickup = widget.deliveryTask.pickupLocation;
    final delivery = widget.deliveryTask.deliveryLocation;
    
    int steps = 0;
    const totalSteps = 20;
    
    _locationSubscription = Stream.periodic(
      const Duration(seconds: 2),
      (count) {
        steps = count.clamp(0, totalSteps);
        final progress = steps / totalSteps;
        
        return GeoPoint(
          pickup.latitude + (delivery.latitude - pickup.latitude) * progress,
          pickup.longitude + (delivery.longitude - pickup.longitude) * progress,
        );
      },
    ).take(totalSteps + 1).listen((location) {
      setState(() {
        _riderLocation = location;
        _progress = steps / totalSteps;
      });
      
      _updateRiderLocation(location);
      widget.onLocationUpdate?.call(location);
    });
  }

  void _loadRiderLocation() {
    // Listen for rider location updates from Firestore
    _locationSubscription = FirebaseFirestore.instance
        .collection('delivery_tasks')
        .doc(widget.deliveryTask.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['riderLocation'] != null) {
          final location = data['riderLocation'] as GeoPoint;
          setState(() {
            _riderLocation = location;
            _calculateProgress();
          });
        }
      }
    });
  }

  void _updateRiderLocation(GeoPoint location) {
    FirebaseFirestore.instance
        .collection('delivery_tasks')
        .doc(widget.deliveryTask.id)
        .update({'riderLocation': location});
  }

  void _calculateProgress() {
    if (_riderLocation == null) return;
    
    final pickup = widget.deliveryTask.pickupLocation;
    final delivery = widget.deliveryTask.deliveryLocation;
    
    final totalDistance = _calculateDistance(pickup, delivery);
    final remainingDistance = _calculateDistance(_riderLocation!, delivery);
    
    setState(() {
      _progress = 1.0 - (remainingDistance / totalDistance);
      _progress = _progress.clamp(0.0, 1.0);
    });
  }

  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // km
    
    final dLat = (point2.latitude - point1.latitude) * (math.pi / 180);
    final dLng = (point2.longitude - point1.longitude) * (math.pi / 180);
    
    final lat1Rad = point1.latitude * (math.pi / 180);
    final lat2Rad = point2.latitude * (math.pi / 180);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1Rad) * math.cos(lat2Rad) *
              math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Placeholder
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.contain,
              opacity: 0.1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Interactive Map',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time tracking will be displayed here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          
        // Progress indicator
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delivery Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}% Complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Location info card
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.deliveryTask.deliveryAddress,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Distance: ${widget.deliveryTask.formattedDistance}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        'ETA: ${widget.deliveryTask.estimatedDeliveryTime}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
