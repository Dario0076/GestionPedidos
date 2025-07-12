import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/translated_text.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final createOrderState = ref.watch(createOrderProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const TranslatedText(
          'Mi Carrito',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, ref),
              child: const TranslatedText(
                'Limpiar',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // Lista de productos en el carrito
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemCard(
                        item: item,
                        onQuantityChanged: (quantity) {
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.product.id, quantity);
                        },
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeItem(item.product.id);
                        },
                      );
                    },
                  ),
                ),

                // Resumen y botón de pago
                _buildBottomSection(context, ref, cart, createOrderState),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          TranslatedText(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TranslatedText(
            'Agrega productos para continuar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const TranslatedText('Explorar Productos'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    WidgetRef ref,
    cart,
    createOrderState,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Resumen del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TranslatedText(
                  '${cart.totalItems} ${cart.totalItems == 1 ? 'producto' : 'productos'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                TranslatedText(
                  'Subtotal: \$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón de checkout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: createOrderState.isLoading
                    ? null
                    : () => _checkout(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: createOrderState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : TranslatedText(
                        'Realizar Pedido - \$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Limpiar Carrito'),
        content: const TranslatedText(
          '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.of(context).pop();
            },
            child: const TranslatedText(
              'Limpiar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    try {
      print('CartScreen: Starting checkout process...');
      final cart = ref.read(cartProvider);
      print(
        'CartScreen: Cart has ${cart.totalItems} items, total: \$${cart.total}',
      );

      print('CartScreen: Calling createOrder...');
      final success = await ref
          .read(createOrderProvider.notifier)
          .createOrder(cart);
      print('CartScreen: createOrder returned: $success');

      if (success && context.mounted) {
        print('CartScreen: Order created successfully, clearing cart...');
        // Limpiar carrito después del pedido exitoso
        ref.read(cartProvider.notifier).clearCart();

        print('CartScreen: Showing success message...');
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TranslatedText('¡Pedido realizado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        print('CartScreen: Navigating to orders screen...');
        // Navegar a la pantalla de pedidos
        context.go('/orders');
      } else {
        print('CartScreen: Order creation failed or context not mounted');
        final createOrderState = ref.read(createOrderProvider);
        if (createOrderState.error != null) {
          print('CartScreen: Error from provider: ${createOrderState.error}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TranslatedText('Error: ${createOrderState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('CartScreen: Exception during checkout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TranslatedText('Error al realizar el pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
