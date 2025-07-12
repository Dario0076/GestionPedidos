import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  Cart addItem(Product product, {int quantity = 1}) {
    final existingItemIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      // Si el producto ya existe, actualizar la cantidad
      final updatedItems = List<CartItem>.from(items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      return Cart(items: updatedItems);
    } else {
      // Si el producto no existe, agregarlo
      return Cart(items: [...items, CartItem(product: product, quantity: quantity)]);
    }
  }

  Cart removeItem(String productId) {
    return Cart(items: items.where((item) => item.product.id != productId).toList());
  }

  Cart updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  Cart clear() {
    return const Cart(items: []);
  }

  @override
  String toString() {
    return 'Cart(items: ${items.length}, total: \$${total.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && 
           other.items.length == items.length &&
           other.items.every((item) => items.contains(item));
  }

  @override
  int get hashCode => items.hashCode;
}
