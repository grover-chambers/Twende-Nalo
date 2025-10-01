import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/shop_service.dart';

class ShopProvider extends ChangeNotifier {
  ShopService get shopService => _shopService;
  final ShopService _shopService = ShopService(); 
  List<Shop> _shops = [];
  bool _isLoading = false;
  String _error = '';

  List<Shop> get shops => _shops;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadShops() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _shops = await _shopService.getAllShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchShops(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _shops = await _shopService.searchShops(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterShopsByCategory(String category) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _shops = await _shopService.getShopsByCategory(category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshShops() async {
    await loadShops();
  }
}
