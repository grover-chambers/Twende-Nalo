import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/promo_provider.dart';
import '../widgets/promo_banner.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromoProvider>().fetchPromos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promos'),
      ),
      body: Consumer<PromoProvider>(
        builder: (context, promoProvider, child) {
          if (promoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (promoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${promoProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      promoProvider.fetchPromos();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (promoProvider.promos.isEmpty) {
            return const Center(
              child: Text('No promos available at the moment.'),
            );
          }

          return ListView.builder(
            itemCount: promoProvider.promos.length,
            itemBuilder: (context, index) {
              final promo = promoProvider.promos[index];
              return PromoBanner(promo: promo);
            },
          );
        },
      ),
    );
  }
}
