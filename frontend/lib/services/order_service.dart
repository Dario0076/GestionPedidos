import '../models/order.dart';
import '../models/cart.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiService _apiService = ApiService();

  // Crear un nuevo pedido desde el carrito
  Future<Order> createOrder(Cart cart, {String? notes}) async {
    try {
      print('OrderService: Creating order...');
      if (cart.isEmpty) {
        throw ApiException(message: 'El carrito está vacío');
      }

      final orderDetails = cart.items.map((item) => OrderDetailRequest(
        productId: item.product.id,
        quantity: item.quantity,
      )).toList();

      final createOrderRequest = CreateOrderRequest(
        orderDetails: orderDetails,
        notes: notes,
      );

      print('OrderService: Making POST request to create order...');
      final response = await _apiService.post(
        ApiConstants.orders,
        data: createOrderRequest.toJson(),
      );

      print('OrderService: Response received with status ${response.statusCode}');
      print('OrderService: Response data type: ${response.data.runtimeType}');
      print('OrderService: Response data: ${response.data}');
      
      try {
        print('OrderService: Attempting to parse Order from JSON...');
        final order = Order.fromJson(response.data);
        print('OrderService: Successfully created order: ${order.id}');
        return order;
      } catch (e) {
        print('OrderService: Error parsing Order JSON: $e');
        print('OrderService: Raw response data: ${response.data}');
        rethrow;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('OrderService: Unexpected error creating order: $e');
      throw ApiException(message: 'Error al crear el pedido');
    }
  }

  // Obtener todos los pedidos del usuario actual
  Future<List<Order>> getUserOrders() async {
    try {
      print('OrderService: Getting user orders...');
      final response = await _apiService.get(ApiConstants.orders);

      print('OrderService: Response received with status ${response.statusCode}');
      print('OrderService: Response data type: ${response.data.runtimeType}');
      
      final data = response.data as List;
      print('OrderService: Found ${data.length} orders');
      print('OrderService: First order data: ${data.isNotEmpty ? data[0] : "No orders"}');
      
      final orders = <Order>[];
      for (int i = 0; i < data.length; i++) {
        try {
          print('OrderService: Processing order $i: ${data[i]['id']}');
          final order = Order.fromJson(data[i]);
          orders.add(order);
          print('OrderService: Successfully parsed order: ${order.id}');
        } catch (e) {
          print('OrderService: Error parsing order $i: $e');
          print('OrderService: Order data: ${data[i]}');
          rethrow;
        }
      }
      
      print('OrderService: Successfully parsed ${orders.length} orders');
      return orders;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar los pedidos');
    }
  }

  // Obtener un pedido específico por ID
  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.orderById(orderId),
      );

      return Order.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar el pedido');
    }
  }

  // Cancelar un pedido
  Future<Order> cancelOrder(String orderId) async {
    try {
      print('OrderService: Canceling order $orderId...');
      final response = await _apiService.patch(
        ApiConstants.orderCancel(orderId),
      );

      print('OrderService: Cancel response status: ${response.statusCode}');
      print('OrderService: Cancel response data: ${response.data}');
      
      final cancelledOrder = Order.fromJson(response.data);
      print('OrderService: Order canceled successfully: ${cancelledOrder.id}, status: ${cancelledOrder.status}');
      return cancelledOrder;
    } on ApiException catch (e) {
      print('OrderService: ApiException canceling order: ${e.message}');
      rethrow;
    } catch (e) {
      print('OrderService: Unexpected error canceling order: $e');
      throw ApiException(message: 'Error al cancelar el pedido');
    }
  }

  // Obtener pedidos filtrados por estado
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final orders = await getUserOrders();
      return orders.where((order) => order.status == status).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al filtrar pedidos por estado');
    }
  }

  // Obtener pedidos recientes (últimos N pedidos)
  Future<List<Order>> getRecentOrders({int limit = 5}) async {
    try {
      final orders = await getUserOrders();
      
      // Ordenar por fecha de creación (más recientes primero)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return orders.take(limit).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar pedidos recientes');
    }
  }

  // Verificar si un pedido se puede cancelar
  bool canCancelOrder(Order order) {
    return order.status == OrderStatus.pending || 
           order.status == OrderStatus.confirmed;
  }

  // Obtener estadísticas básicas de pedidos del usuario
  Future<OrderStats> getOrderStats() async {
    try {
      final orders = await getUserOrders();
      
      int totalOrders = orders.length;
      int completedOrders = orders.where((o) => o.status == OrderStatus.delivered).length;
      int pendingOrders = orders.where((o) => 
        o.status == OrderStatus.pending || 
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.preparing ||
        o.status == OrderStatus.shipped
      ).length;
      int cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).length;
      
      double totalSpent = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, order) => sum + order.total);

      return OrderStats(
        totalOrders: totalOrders,
        completedOrders: completedOrders,
        pendingOrders: pendingOrders,
        cancelledOrders: cancelledOrders,
        totalSpent: totalSpent,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al calcular estadísticas');
    }
  }
}

class OrderStats {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final double totalSpent;

  const OrderStats({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.totalSpent,
  });

  @override
  String toString() {
    return 'OrderStats(total: $totalOrders, completed: $completedOrders, pending: $pendingOrders, cancelled: $cancelledOrders, spent: \$${totalSpent.toStringAsFixed(2)})';
  }
}
