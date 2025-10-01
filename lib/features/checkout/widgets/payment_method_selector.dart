import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment_method.dart';
import '../providers/checkout_provider.dart';

class PaymentMethodSelector extends StatelessWidget {
  final Function(PaymentType)? onPaymentTypeChanged;

  const PaymentMethodSelector({
    Key? key,
    this.onPaymentTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...PaymentType.values.map((type) => _buildPaymentMethodCard(type, checkoutProvider, context)),
            if (checkoutProvider.selectedPaymentType == PaymentType.mpesa) ...[
              const SizedBox(height: 16),
              _buildMpesaForm(checkoutProvider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentType type, CheckoutProvider checkoutProvider, BuildContext context) {
    final isSelected = checkoutProvider.selectedPaymentType == type;
    final paymentInfo = _getPaymentMethodInfo(type);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          checkoutProvider.setPaymentType(type);
          onPaymentTypeChanged?.call(type);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  paymentInfo['icon'] as IconData,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                      ),
                    ),
                    Text(
                      paymentInfo['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<PaymentType>(
                value: type,
                groupValue: checkoutProvider.selectedPaymentType,
                onChanged: (value) {
                  if (value != null) {
                    checkoutProvider.setPaymentType(value);
                    onPaymentTypeChanged?.call(value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMpesaForm(CheckoutProvider checkoutProvider) {
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
              'M-Pesa Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: checkoutProvider.phoneNumber,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '07XXXXXXXX',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (!RegExp(r'^07\d{8}$').hasMatch(value)) {
                  return 'Please enter valid M-Pesa number';
                }
                return null;
              },
              onChanged: (value) {
                checkoutProvider.setPhoneNumber(value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive an M-Pesa prompt to complete payment',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPaymentMethodInfo(PaymentType type) {
    switch (type) {
      case PaymentType.mpesa:
        return {
          'icon': Icons.phone_android,
          'description': 'Pay with M-Pesa mobile money',
        };
      case PaymentType.card:
        return {
          'icon': Icons.credit_card,
          'description': 'Pay with credit or debit card',
        };
      case PaymentType.cash:
        return {
          'icon': Icons.money,
          'description': 'Pay cash when your order arrives',
        };
      case PaymentType.wallet:
        return {
          'icon': Icons.account_balance_wallet,
          'description': 'Pay from your wallet balance',
        };
      case PaymentType.bankTransfer:
        return {
          'icon': Icons.account_balance,
          'description': 'Pay via bank transfer',
        };
    }
  }
}

/// Widget for displaying saved payment methods
class SavedPaymentMethodsList extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final ValueChanged<PaymentMethod> onSelected;
  final PaymentMethod? selectedMethod;

  const SavedPaymentMethodsList({
    Key? key,
    required this.paymentMethods,
    required this.onSelected,
    this.selectedMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Payment Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...paymentMethods.map((method) => _buildSavedMethodCard(method, context)),
      ],
    );
  }

  Widget _buildSavedMethodCard(PaymentMethod method, BuildContext context) {
    final isSelected = selectedMethod?.id == method.id;
    final displayInfo = method.getDisplayInfo();

    return Card(
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: ListTile(
        leading: Icon(
          _getIconForType(method.type),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(displayInfo['title']!),
        subtitle: Text(displayInfo['details']!),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () => onSelected(method),
      ),
    );
  }

  IconData _getIconForType(PaymentType type) {
    switch (type) {
      case PaymentType.mpesa:
        return Icons.phone_android;
      case PaymentType.card:
        return Icons.credit_card;
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.wallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
    }
  }
}
