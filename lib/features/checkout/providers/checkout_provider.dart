import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';

class CheckoutProvider extends ChangeNotifier {
  // State variables
  List<Map<String, dynamic>> _cartItems = [];
  String? _deliveryAddress;
  PaymentType _selectedPaymentType = PaymentType.mpesa;
  String? _phoneNumber;
  String? _promoCode;
  double _discountAmount = 0.0;
  double _deliveryFee = 5.0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _orderId;

  // Getters
  List<Map<String, dynamic>> get cartItems => _cartItems;
  String? get deliveryAddress => _deliveryAddress;
  PaymentType get selectedPaymentType => _selectedPaymentType;
  String? get phoneNumber => _phoneNumber;
  String? get promoCode => _promoCode;
  double get discountAmount => _discountAmount;
  double get deliveryFee => _deliveryFee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get orderId => _orderId;

  // Computed properties
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get totalAmount {
    return subtotal + _deliveryFee - _discountAmount;
  }

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  // Setters
  void setCartItems(List<Map<String, dynamic>> items) {
    _cartItems = List.from(items);
    notifyListeners();
  }

  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setPaymentType(PaymentType type) {
    _selectedPaymentType = type;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setPromoCode(String code) {
    _promoCode = code;
    _validatePromoCode();
    notifyListeners();
  }

  // Private methods
  Future<void> _validatePromoCode() async {
    if (_promoCode == null || _promoCode!.isEmpty) {
      _discountAmount = 0.0;
      return;
    }

    // Simple promo code validation
    if (_promoCode == 'SAVE10') {
      _discountAmount = subtotal * 0.1;
    } else if (_promoCode == 'SAVE5') {
      _discountAmount = 5.0;
    } else {
      _discountAmount = 0.0;
    }
  }

  // Public methods
  Future<bool> processPayment() async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return false;
    }

    if (_deliveryAddress == null || _deliveryAddress!.isEmpty) {
      _errorMessage = 'Please select delivery address';
      notifyListeners();
      return false;
    }

    if (_selectedPaymentType == PaymentType.mpesa && 
        (_phoneNumber == null || _phoneNumber!.isEmpty)) {
      _errorMessage = 'Please enter phone number for M-Pesa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate order ID
      _orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      return true;
    } catch (e) {
      _errorMessage = 'Payment failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetCheckout() {
    _cartItems.clear();
    _deliveryAddress = null;
    _selectedPaymentType = PaymentType.mpesa;
    _phoneNumber = null;
    _promoCode = null;
    _discountAmount = 0.0;
    _orderId = null;
    notifyListeners();
  }

  // Validation methods
  bool validateCheckout() {
    if (_cartItems.isEmpty) {
      _errorMessage = 'Your cart is empty';
      return false;
    }

    if (_deliveryAddress == null || _deliveryAddress!.isEmpty) {
      _errorMessage = 'Please select a delivery address';
      return false;
    }

    if (_selectedPaymentType == PaymentType.mpesa && 
        (_phoneNumber == null || _phoneNumber!.isEmpty)) {
      _errorMessage = 'Please enter a valid phone number';
      return false;
    }

    return true;
  }

  // Utility methods
  String formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> getCheckoutSummary() {
    return {
      'items': _cartItems,
      'subtotal': subtotal,
      'deliveryFee': _deliveryFee,
      'discountAmount': _discountAmount,
      'totalAmount': totalAmount,
      'deliveryAddress': _deliveryAddress,
      'paymentType': _selectedPaymentType.name,
      'phoneNumber': _phoneNumber,
      'promoCode': _promoCode,
    };
  }
}
