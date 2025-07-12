import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order.dart';
import '../../../services/api_service.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  List<Order> orders = [];
  bool isLoading = true;
  String? error;
  String selectedStatus = 'ALL';

  final List<String> statusOptions = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED'
  ];

  final Map<String, String> statusLabels = {
    'ALL': 'Todos',
    'PENDING': 'Pendiente',
    'CONFIRMED': 'Confirmado',
    'PREPARING': 'Preparando',
    'SHIPPED': 'Enviado',
    'DELIVERED': 'Entregado',
    'CANCELLED': 'Cancelado'
  };

  final Map<String, Color> statusColors = {
    'PENDING': Colors.orange,
    'CONFIRMED': Colors.blue,
    'PREPARING': Colors.indigo,
    'SHIPPED': Colors.purple,
    'DELIVERED': Colors.green,
    'CANCELLED': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ApiService();
      final response = await apiService.get('/orders');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        orders = data.map((json) => Order.fromJson(json)).toList();
        
        // Ordenar por fecha de creación (más recientes primero)
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        throw Exception('Error al cargar pedidos: ${response.statusCode}');
      }
    } catch (e) {
      error = 'Error al cargar pedidos: $e';
      print('Error loading orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Order> get filteredOrders {
    if (selectedStatus == 'ALL') return orders;
    return orders.where((order) => order.status.value == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Gestionar Pedidos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _buildErrorState(context)
                    : _buildOrdersList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por estado:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusOptions.map((status) {
                final isSelected = selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(statusLabels[status]!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                    selectedColor: statusColors[status]?.withOpacity(0.2),
                    checkmarkColor: statusColors[status],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrders,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    final filtered = filteredOrders;
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              selectedStatus == 'ALL' 
                  ? 'No hay pedidos registrados'
                  : 'No hay pedidos con estado ${statusLabels[selectedStatus]}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final order = filtered[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColors[order.status.value]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: statusColors[order.status.value],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Usuario ID: ${order.userId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDate(order.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (order.orderDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Productos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...order.orderDetails.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Text(
                      '• ${item.product?.name ?? 'Producto N/A'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status.value != 'CANCELLED' && order.status.value != 'DELIVERED')
                  TextButton.icon(
                    onPressed: () => _showUpdateStatusDialog(context, order),
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('Actualizar Estado'),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showOrderDetails(context, order),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver Detalles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showUpdateStatusDialog(BuildContext context, Order order) {
    String newStatus = order.status.value;
    
    // Determinar los estados disponibles según el estado actual
    List<String> availableStatuses = [];
    switch (order.status.value) {
      case 'PENDING':
        availableStatuses = ['CONFIRMED', 'CANCELLED'];
        break;
      case 'CONFIRMED':
        availableStatuses = ['PREPARING', 'CANCELLED'];
        break;
      case 'PREPARING':
        availableStatuses = ['SHIPPED', 'CANCELLED'];
        break;
      case 'SHIPPED':
        availableStatuses = ['DELIVERED'];
        break;
      default:
        availableStatuses = [];
    }

    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay estados disponibles para actualizar')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Estado - Pedido #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado actual: ${order.status.displayName}'),
            const SizedBox(height: 16),
            const Text('Nuevo estado:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: availableStatuses.contains(newStatus) ? newStatus : availableStatuses.first,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: availableStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(statusLabels[status]!),
                );
              }).toList(),
              onChanged: (value) {
                newStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updateOrderStatus(context, order, newStatus),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, Order order, String newStatus) async {
    try {
      final apiService = ApiService();
      await apiService.patch('/orders/${order.id}', data: {'status': newStatus});
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a ${statusLabels[newStatus]}')),
        );
        _loadOrders();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Pedido #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Estado', order.status.displayName),
              _buildDetailRow('Usuario ID', order.userId.toString()),
              _buildDetailRow('Total', '\$${order.total.toStringAsFixed(2)}'),
              _buildDetailRow('Fecha de creación', _formatDate(order.createdAt)),
              _buildDetailRow('Última actualización', _formatDate(order.updatedAt)),
              const SizedBox(height: 16),
              const Text(
                'Productos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.orderDetails.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.name ?? 'Producto N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Cantidad: ${item.quantity}'),
                      Text('Precio unitario: \$${item.price.toStringAsFixed(2)}'),
                      Text('Subtotal: \$${(item.quantity * item.price).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
