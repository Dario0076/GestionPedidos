import 'package:flutter/material.dart';
import '../models/cart.dart';
import 'translated_text.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: (item.product.imageUrl?.isNotEmpty ?? false)
                    ? Image.network(
                        item.product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),

            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Precio unitario
                  TranslatedText(
                    '\$${item.product.price.toStringAsFixed(2)} c/u',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 8),

                  // Controles de cantidad y precio total
                  Row(
                    children: [
                      // Controles de cantidad
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón decrementar
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed: item.quantity > 1
                                    ? () => onQuantityChanged(item.quantity - 1)
                                    : null,
                                icon: const Icon(Icons.remove, size: 16),
                                padding: EdgeInsets.zero,
                              ),
                            ),

                            // Cantidad actual
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Botón incrementar
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed: item.quantity < item.product.stock
                                    ? () => onQuantityChanged(item.quantity + 1)
                                    : null,
                                icon: const Icon(Icons.add, size: 16),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Precio total del item
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Botón eliminar
            IconButton(
              onPressed: () => _showRemoveDialog(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 24,
        color: Colors.grey,
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Eliminar producto'),
        content: TranslatedText(
          '¿Quieres eliminar "${item.product.name}" del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRemove();
            },
            child: const TranslatedText(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
