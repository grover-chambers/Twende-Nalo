class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;
  final String? selectedOptions;
  final String shopId;
  final String shopName;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedOptions,
    required this.shopId,
    required this.shopName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'shopId': shopId,
      'shopName': shopName,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      selectedOptions: json['selectedOptions'],
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }

  double get totalPrice => price * quantity;
}
