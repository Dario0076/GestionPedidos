import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(StorageKeys.cart);
      
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
        final items = (cartData['items'] as List)
            .map((item) => CartItem(
                  product: Product.fromJson(item['product']),
                  quantity: item['quantity'] as int,
                ))
            .toList();
        
        state = Cart(items: items);
      }
    } catch (e) {
      // Si hay error al cargar, empezar con carrito vacío
      state = const Cart();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': state.items
            .map((item) => {
                  'product': item.product.toJson(),
                  'quantity': item.quantity,
                })
            .toList(),
      };
      
      await prefs.setString(StorageKeys.cart, jsonEncode(cartData));
    } catch (e) {
      // Error al guardar, pero no interrumpir la operación
      // En producción esto podría enviarse a un servicio de logging
    }
  }

  void addItem(Product product, {int quantity = 1}) {
    if (quantity <= 0 || product.stock < quantity) {
      return;
    }

    state = state.addItem(product, quantity: quantity);
    _saveCart();
  }

  // Alias para compatibilidad
  void addToCart(Product product, {int quantity = 1}) {
    addItem(product, quantity: quantity);
  }

  void removeItem(String productId) {
    state = state.removeItem(productId);
    _saveCart();
  }

  void updateQuantity(String productId, int quantity) {
    final item = state.getItem(productId);
    if (item == null) return;

    // Verificar stock disponible
    if (quantity > item.product.stock) {
      return;
    }

    state = state.updateQuantity(productId, quantity);
    _saveCart();
  }

  void incrementQuantity(String productId) {
    final item = state.getItem(productId);
    if (item == null) return;

    final newQuantity = item.quantity + 1;
    if (newQuantity <= item.product.stock) {
      updateQuantity(productId, newQuantity);
    }
  }

  void decrementQuantity(String productId) {
    final item = state.getItem(productId);
    if (item == null) return;

    final newQuantity = item.quantity - 1;
    updateQuantity(productId, newQuantity);
  }

  void clearCart() {
    state = const Cart();
    _saveCart();
  }

  bool canAddToCart(Product product, int quantity) {
    final currentItem = state.getItem(product.id);
    final currentQuantity = currentItem?.quantity ?? 0;
    final totalQuantity = currentQuantity + quantity;
    
    return totalQuantity <= product.stock;
  }

  int getQuantityInCart(String productId) {
    final item = state.getItem(productId);
    return item?.quantity ?? 0;
  }

  double get total => state.total;
  int get totalItems => state.totalItems;
  bool get isEmpty => state.isEmpty;
  bool get isNotEmpty => state.isNotEmpty;
  List<CartItem> get items => state.items;
}

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

// Providers auxiliares para facilitar el acceso a propiedades del carrito
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

// Provider para verificar si un producto está en el carrito
final productInCartProvider = ProviderFamily<CartItem?, String>((ref, productId) {
  final cart = ref.watch(cartProvider);
  return cart.getItem(productId);
});

// Provider para obtener la cantidad de un producto específico en el carrito
final productQuantityInCartProvider = ProviderFamily<int, String>((ref, productId) {
  final cartItem = ref.watch(productInCartProvider(productId));
  return cartItem?.quantity ?? 0;
});
