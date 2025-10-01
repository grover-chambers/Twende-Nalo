import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkout_provider.dart';
import '../models/payment_method.dart';
import '../../../core/widgets/app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final checkoutProvider = context.read<CheckoutProvider>();
    _phoneController.text = checkoutProvider.phoneNumber ?? '';
    _promoController.text = checkoutProvider.promoCode ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Checkout'),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(checkoutProvider),
                  const SizedBox(height: 24),
                  _buildDeliveryAddressSection(checkoutProvider),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSection(checkoutProvider),
                  const SizedBox(height: 24),
                  _buildPromoCodeSection(checkoutProvider),
                  const SizedBox(height: 32),
                  _buildPlaceOrderButton(checkoutProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CheckoutProvider checkoutProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...checkoutProvider.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['name']} x${item['quantity']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    checkoutProvider.formatCurrency(item['price'] * item['quantity']),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            _buildSummaryRow('Subtotal', checkoutProvider.formatCurrency(checkoutProvider.subtotal)),
            _buildSummaryRow('Delivery Fee', checkoutProvider.formatCurrency(checkoutProvider.deliveryFee)),
            if (checkoutProvider.discountAmount > 0)
              _buildSummaryRow('Discount', '-${checkoutProvider.formatCurrency(checkoutProvider.discountAmount)}'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              checkoutProvider.formatCurrency(checkoutProvider.totalAmount),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection(CheckoutProvider checkoutProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: checkoutProvider.deliveryAddress,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter your delivery address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
              onChanged: (value) {
                checkoutProvider.setDeliveryAddress(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutProvider checkoutProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...PaymentType.values.map((type) => _buildPaymentOption(type, checkoutProvider)),
            if (checkoutProvider.selectedPaymentType == PaymentType.mpesa) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  hintText: '07XXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (checkoutProvider.selectedPaymentType == PaymentType.mpesa) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (!RegExp(r'^07\d{8}$').hasMatch(value)) {
                      return 'Please enter valid phone number';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  checkoutProvider.setPhoneNumber(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(PaymentType type, CheckoutProvider checkoutProvider) {
    return RadioListTile<PaymentType>(
      title: Text(type.name),
      subtitle: Text(_getPaymentDescription(type)),
      value: type,
      groupValue: checkoutProvider.selectedPaymentType,
      onChanged: (value) {
        if (value != null) {
          checkoutProvider.setPaymentType(value);
        }
      },
    );
  }

  String _getPaymentDescription(PaymentType type) {
    switch (type) {
      case PaymentType.mpesa:
        return 'Pay with M-Pesa mobile money';
      case PaymentType.card:
        return 'Pay with credit/debit card';
      case PaymentType.cash:
        return 'Pay cash on delivery';
      case PaymentType.wallet:
        return 'Pay from your wallet';
      case PaymentType.bankTransfer:
        return 'Pay via bank transfer';
    }
  }

  Widget _buildPromoCodeSection(CheckoutProvider checkoutProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promo Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _promoController,
                    decoration: const InputDecoration(
                      labelText: 'Promo Code',
                      hintText: 'Enter promo code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                    onChanged: (value) {
                      checkoutProvider.setPromoCode(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    checkoutProvider.setPromoCode(_promoController.text);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            if (checkoutProvider.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Discount applied: ${checkoutProvider.formatCurrency(checkoutProvider.discountAmount)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CheckoutProvider checkoutProvider) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: checkoutProvider.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  final success = await checkoutProvider.processPayment();
                  if (success && mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/confirmation',
                      arguments: checkoutProvider.orderId,
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: checkoutProvider.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Place Order - ${checkoutProvider.formatCurrency(checkoutProvider.totalAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
