import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Enum representing different payment methods available in the app
enum PaymentType {
  mpesa,
  card,
  cash,
  wallet,
  bankTransfer,
}

/// Extension for PaymentType to provide additional functionality
extension PaymentTypeExtension on PaymentType {
  String get name {
    switch (this) {
      case PaymentType.mpesa:
        return 'M-Pesa';
      case PaymentType.card:
        return 'Credit/Debit Card';
      case PaymentType.cash:
        return 'Cash on Delivery';
      case PaymentType.wallet:
        return 'Wallet';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String get icon {
    switch (this) {
      case PaymentType.mpesa:
        return 'assets/icons/mpesa.png';
      case PaymentType.card:
        return 'assets/icons/card.png';
      case PaymentType.cash:
        return 'assets/icons/cash.png';
      case PaymentType.wallet:
        return 'assets/icons/wallet.png';
      case PaymentType.bankTransfer:
        return 'assets/icons/bank.png';
    }
  }

  bool get requiresAdditionalDetails {
    switch (this) {
      case PaymentType.mpesa:
      case PaymentType.card:
      case PaymentType.bankTransfer:
        return true;
      case PaymentType.cash:
      case PaymentType.wallet:
        return false;
    }
  }

  bool get supportsSaveForLater {
    switch (this) {
      case PaymentType.mpesa:
      case PaymentType.card:
      case PaymentType.wallet:
        return true;
      case PaymentType.cash:
      case PaymentType.bankTransfer:
        return false;
    }
  }
}

/// Model representing a payment method
class PaymentMethod {
  final String id;
  final PaymentType type;
  final String name;
  final String? description;
  final bool isActive;
  final bool isDefault;
  final Map<String, dynamic>? details;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.isActive = true,
    this.isDefault = false,
    this.details,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Factory constructor for M-Pesa payment
  factory PaymentMethod.mpesa({
    required String phoneNumber,
    String? name,
  }) {
    return PaymentMethod(
      id: 'mpesa_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.mpesa,
      name: name ?? 'M-Pesa',
      description: 'Pay with M-Pesa mobile money',
      details: {
        'phoneNumber': phoneNumber,
        'provider': 'Safaricom',
      },
    );
  }

  /// Factory constructor for Card payment
  factory PaymentMethod.card({
    required String cardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    String? cvv,
  }) {
    return PaymentMethod(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.card,
      name: 'Card ending ${cardNumber.substring(cardNumber.length - 4)}',
      description: 'Credit/Debit card payment',
      details: {
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'last4': cardNumber.substring(cardNumber.length - 4),
        'brand': _detectCardBrand(cardNumber),
      },
    );
  }

  /// Factory constructor for Cash on Delivery
  factory PaymentMethod.cashOnDelivery() {
    return PaymentMethod(
      id: 'cash_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.cash,
      name: 'Cash on Delivery',
      description: 'Pay with cash when your order arrives',
    );
  }

  /// Factory constructor for Wallet payment
  factory PaymentMethod.wallet({
    required String walletId,
    required double balance,
    String? name,
  }) {
    return PaymentMethod(
      id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.wallet,
      name: name ?? 'Wallet',
      description: 'Pay from your wallet balance',
      details: {
        'walletId': walletId,
        'balance': balance,
      },
    );
  }

  /// Factory constructor for Bank Transfer
  factory PaymentMethod.bankTransfer({
    required String accountNumber,
    required String bankName,
    String? accountName,
  }) {
    return PaymentMethod(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.bankTransfer,
      name: 'Bank Transfer',
      description: 'Pay via bank transfer',
      details: {
        'accountNumber': accountNumber,
        'bankName': bankName,
        'accountName': accountName,
      },
    );
  }

  /// Copy with method for creating modified instances
  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? name,
    String? description,
    bool? isActive,
    bool? isDefault,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'isActive': isActive,
      'isDefault': isDefault,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.cash,
      ),
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
      details: json['details'] != null 
          ? Map<String, dynamic>.from(json['details'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Validate payment method details
  bool validate() {
    switch (type) {
      case PaymentType.mpesa:
        return details?['phoneNumber'] != null && 
               details!['phoneNumber'].toString().length >= 10;
      case PaymentType.card:
        return details?['cardNumber'] != null && 
               details?['cardHolderName'] != null &&
               details?['expiryMonth'] != null &&
               details?['expiryYear'] != null;
      case PaymentType.cash:
        return true;
      case PaymentType.wallet:
        return details?['walletId'] != null;
      case PaymentType.bankTransfer:
        return details?['accountNumber'] != null &&
               details?['bankName'] != null;
    }
  }

  /// Get display information
  Map<String, String> getDisplayInfo() {
    switch (type) {
      case PaymentType.mpesa:
        return {
          'title': name,
          'subtitle': description ?? 'M-Pesa mobile payment',
          'details': 'Phone: ${details?['phoneNumber'] ?? 'Not set'}',
        };
      case PaymentType.card:
        return {
          'title': name,
          'subtitle': description ?? 'Card payment',
          'details': 'Card ending ${details?['last4'] ?? '****'}',
        };
      case PaymentType.cash:
        return {
          'title': name,
          'subtitle': description ?? 'Pay on delivery',
          'details': 'Cash payment',
        };
      case PaymentType.wallet:
        return {
          'title': name,
          'subtitle': description ?? 'Wallet payment',
          'details': 'Balance: KES ${details?['balance']?.toStringAsFixed(2) ?? '0.00'}',
        };
      case PaymentType.bankTransfer:
        return {
          'title': name,
          'subtitle': description ?? 'Bank transfer',
          'details': '${details?['bankName'] ?? 'Bank'} - ${details?['accountNumber'] ?? '****'}',
        };
    }
  }

  /// Check if payment method is expired (for cards)
  bool get isExpired {
    if (type != PaymentType.card) return false;
    
    final expiryMonth = int.tryParse(details?['expiryMonth'] ?? '');
    final expiryYear = int.tryParse(details?['expiryYear'] ?? '');
    
    if (expiryMonth == null || expiryYear == null) return true;
    
    final now = DateTime.now();
    final expiryDate = DateTime(expiryYear + 2000, expiryMonth);
    
    return now.isAfter(expiryDate);
  }

  /// Get masked card number for display
  String get maskedCardNumber {
    if (type != PaymentType.card) return '';
    
    final last4 = details?['last4'] ?? '****';
    return '**** **** **** $last4';
  }

  /// Check if payment method can be used for amount
  bool canPayAmount(double amount) {
    if (type == PaymentType.wallet) {
      final balance = details?['balance'] ?? 0.0;
      return balance >= amount;
    }
    return true;
  }

  /// Clone payment method
  PaymentMethod clone() {
    return PaymentMethod(
      id: id,
      type: type,
      name: name,
      description: description,
      isActive: isActive,
      isDefault: isDefault,
      details: details != null ? Map<String, dynamic>.from(details!) : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: ${type.name}, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod &&
        other.id == id &&
        other.type == type &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ name.hashCode;
}

/// Helper function to detect card brand
String _detectCardBrand(String cardNumber) {
  if (cardNumber.startsWith('4')) return 'Visa';
  if (cardNumber.startsWith('5')) return 'Mastercard';
  if (cardNumber.startsWith('6')) return 'Discover';
  if (cardNumber.startsWith('3')) return 'American Express';
  return 'Card';
}

/// Payment method manager for handling multiple payment methods
class PaymentMethodManager {
  final List<PaymentMethod> _paymentMethods = [];

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  List<PaymentMethod> get activePaymentMethods => 
      _paymentMethods.where((method) => method.isActive).toList();
  PaymentMethod? get defaultPaymentMethod => 
      _paymentMethods.firstWhere((method) => method.isDefault, orElse: () => _paymentMethods.first);

  /// Add payment method
  void addPaymentMethod(PaymentMethod method) {
    if (method.isDefault) {
      _clearDefaultFlag();
    }
    _paymentMethods.add(method);
  }

  /// Remove payment method
  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((method) => method.id == id);
  }

  /// Update payment method
  void updatePaymentMethod(PaymentMethod updatedMethod) {
    final index = _paymentMethods.indexWhere((method) => method.id == updatedMethod.id);
    if (index != -1) {
      if (updatedMethod.isDefault) {
        _clearDefaultFlag();
      }
      _paymentMethods[index] = updatedMethod;
    }
  }

  /// Set default payment method
  void setDefaultPaymentMethod(String id) {
    _clearDefaultFlag();
    final index = _paymentMethods.indexWhere((method) => method.id == id);
    if (index != -1) {
      _paymentMethods[index] = _paymentMethods[index].copyWith(isDefault: true);
    }
  }

  /// Clear default flag from all methods
  void _clearDefaultFlag() {
    for (int i = 0; i < _paymentMethods.length; i++) {
      _paymentMethods[i] = _paymentMethods[i].copyWith(isDefault: false);
    }
  }

  /// Get payment method by ID
  PaymentMethod? getPaymentMethod(String id) {
    return _paymentMethods.firstWhere((method) => method.id == id);
  }

  /// Get payment methods by type
  List<PaymentMethod> getPaymentMethodsByType(PaymentType type) {
    return _paymentMethods.where((method) => method.type == type).toList();
  }

  /// Validate all payment methods
  List<String> validateAll() {
    final errors = <String>[];
    for (final method in _paymentMethods) {
      if (!method.validate()) {
        errors.add('Invalid ${method.type.name}: ${method.name}');
      }
    }
    return errors;
  }

  /// Convert to JSON
  List<Map<String, dynamic>> toJson() {
    return _paymentMethods.map((method) => method.toJson()).toList();
  }

  /// Create from JSON
  void fromJson(List<dynamic> jsonList) {
    _paymentMethods.clear();
    for (final json in jsonList) {
      _paymentMethods.add(PaymentMethod.fromJson(json));
    }
  }

  /// Clear all payment methods
  void clear() {
    _paymentMethods.clear();
  }
}
