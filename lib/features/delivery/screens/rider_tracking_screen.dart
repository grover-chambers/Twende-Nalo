import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderTrackingScreen extends StatefulWidget {
  final String userId;
  final String riderName;

  const RiderTrackingScreen({
    super.key, 
    required this.userId,
    required this.riderName,
  });

  @override
  _RiderTrackingScreenState createState() => _RiderTrackingScreenState();
}

class _RiderTrackingScreenState extends State<RiderTrackingScreen> {
  String _riderStatus = 'On the way';
  double _deliveryProgress = 0.3; // 30% complete
  bool _isLoading = false;

  // Mock rider data
  final Map<String, dynamic> _riderData = {
    'name': 'John Doe',
    'phone': '+254712345678',
    'rating': 4.8,
    'completedDeliveries': 127,
    'vehicle': 'Motorcycle',
    'plateNumber': 'KCA 123A',
  };

  void _updateRiderStatus() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to update rider status
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        if (_riderStatus == 'On the way') {
          _riderStatus = 'Arrived at pickup';
          _deliveryProgress = 0.5;
        } else if (_riderStatus == 'Arrived at pickup') {
          _riderStatus = 'Picked up order';
          _deliveryProgress = 0.7;
        } else if (_riderStatus == 'Picked up order') {
          _riderStatus = 'On the way to destination';
          _deliveryProgress = 0.9;
        } else {
          _riderStatus = 'Delivered';
          _deliveryProgress = 1.0;
        }
      });
    });
  }

  void _callRider() {
    // Implement call functionality
    // This would typically use url_launcher package
    print('Calling rider: ${_riderData['phone']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rider Tracking',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rider Information Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rider Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        _riderData['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_riderData['vehicle']} • ${_riderData['plateNumber']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            _riderData['rating'].toString(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _riderData['completedDeliveries'].toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _callRider,
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Rider'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Progress
            Text(
              'Delivery Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: _deliveryProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Placed',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _deliveryProgress >= 0.0 ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  'Picked Up',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _deliveryProgress >= 0.5 ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  'Delivered',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _deliveryProgress >= 1.0 ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current Status
            Center(
              child: Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Current Status',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isLoading
                          ? SpinKitCircle(
                              color: Theme.of(context).colorScheme.primary,
                              size: 30.0,
                            )
                          : Text(
                              _riderStatus,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Update Status Button
            Center(
              child: ElevatedButton(
                onPressed: _updateRiderStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Update Status',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
