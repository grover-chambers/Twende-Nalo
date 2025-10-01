import 'dart:async';
import 'package:flutter/material.dart';
import '../models/promo.dart';
import '../services/promo_service.dart';

class PromoProvider extends ChangeNotifier {
  final PromoService _promoService = PromoService();
  
  List<Promo> _promos = [];
  bool _isLoading = false;
  String? _error;

  List<Promo> get promos => _promos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PromoProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchPromos();
  }

  Future<void> fetchPromos() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _promos = await _promoService.getPromos();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
