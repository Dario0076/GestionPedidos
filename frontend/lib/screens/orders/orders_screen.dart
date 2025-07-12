import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../widgets/order_card.dart';
import '../../widgets/translated_text.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const TranslatedText(
          'Mis Pedidos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? _buildEmptyState(context)
            : _buildOrdersList(orders, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _buildErrorState(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const TranslatedText(
            'No tienes pedidos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const TranslatedText(
            'Tus pedidos aparecerán aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
            child: const TranslatedText('Hacer mi primer pedido'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const TranslatedText(
            'Error al cargar pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(ordersProvider),
            child: const TranslatedText('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, WidgetRef ref) {
    // Agrupar pedidos por estado
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final confirmedOrders = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .toList();
    final preparingOrders = orders
        .where((o) => o.status == OrderStatus.preparing)
        .toList();
    final shippedOrders = orders
        .where((o) => o.status == OrderStatus.shipped)
        .toList();
    final deliveredOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();
    final cancelledOrders = orders
        .where((o) => o.status == OrderStatus.cancelled)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(ordersProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pedidos pendientes
            if (pendingOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'Pendientes',
                pendingOrders.length,
                Colors.orange,
              ),
              ...pendingOrders.map((order) => OrderCard(order: order)),
              const SizedBox(height: 16),
            ],

            // Pedidos confirmados
            if (confirmedOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'Confirmados',
                confirmedOrders.length,
                Colors.blue,
              ),
              ...confirmedOrders.map((order) => OrderCard(order: order)),
              const SizedBox(height: 16),
            ],

            // Pedidos en preparación
            if (preparingOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'En Preparación',
                preparingOrders.length,
                Colors.indigo,
              ),
              ...preparingOrders.map((order) => OrderCard(order: order)),
              const SizedBox(height: 16),
            ],

            // Pedidos enviados
            if (shippedOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'Enviados',
                shippedOrders.length,
                Colors.purple,
              ),
              ...shippedOrders.map((order) => OrderCard(order: order)),
              const SizedBox(height: 16),
            ],

            // Pedidos entregados
            if (deliveredOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'Entregados',
                deliveredOrders.length,
                Colors.green,
              ),
              ...deliveredOrders.map((order) => OrderCard(order: order)),
              const SizedBox(height: 16),
            ],

            // Pedidos cancelados
            if (cancelledOrders.isNotEmpty) ...[
              _buildSectionHeader(
                'Cancelados',
                cancelledOrders.length,
                Colors.red,
              ),
              ...cancelledOrders.map((order) => OrderCard(order: order)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          TranslatedText(
            '$title ($count)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
