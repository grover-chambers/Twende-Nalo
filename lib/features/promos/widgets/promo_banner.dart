import 'package:flutter/material.dart';
import '../models/promo.dart';

class PromoBanner extends StatelessWidget {
  final Promo promo;

  const PromoBanner({Key? key, required this.promo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.network(promo.imageUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(promo.description),
                const SizedBox(height: 8),
                Text(
                  'Discount: ${promo.discount}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Logic to apply promo code
                  },
                  child: const Text('Apply Promo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
