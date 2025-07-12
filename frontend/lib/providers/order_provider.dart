import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../services/order_service.dart';

// Provider para el servicio de pedidos
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Provider para todos los pedidos del usuario
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getUserOrders();
});

// Provider para un pedido específico
final orderProvider = FutureProviderFamily<Order, String>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getOrder(orderId);
});

// Provider para pedidos recientes
final recentOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getRecentOrders();
});

// Provider para estadísticas de pedidos
final orderStatsProvider = FutureProvider<OrderStats>((ref) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getOrderStats();
});

// Provider para pedidos filtrados por estado
final ordersByStatusProvider = FutureProviderFamily<List<Order>, OrderStatus>((ref, status) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getOrdersByStatus(status);
});

// Estado para la creación de pedidos
class CreateOrderState {
  final bool isLoading;
  final Order? order;
  final String? error;

  const CreateOrderState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  CreateOrderState copyWith({
    bool? isLoading,
    Order? order,
    String? error,
  }) {
    return CreateOrderState(
      isLoading: isLoading ?? this.isLoading,
      order: order,
      error: error,
    );
  }
}

class CreateOrderNotifier extends StateNotifier<CreateOrderState> {
  final OrderService _orderService;

  CreateOrderNotifier(this._orderService) : super(const CreateOrderState());

  Future<bool> createOrder(Cart cart, {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _orderService.createOrder(cart, notes: notes);
      state = state.copyWith(
        isLoading: false,
        order: order,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const CreateOrderState();
  }
}

final createOrderProvider = StateNotifierProvider<CreateOrderNotifier, CreateOrderState>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return CreateOrderNotifier(orderService);
});

// Estado para cancelar pedidos
class CancelOrderState {
  final bool isLoading;
  final String? cancelledOrderId;
  final String? error;

  const CancelOrderState({
    this.isLoading = false,
    this.cancelledOrderId,
    this.error,
  });

  CancelOrderState copyWith({
    bool? isLoading,
    String? cancelledOrderId,
    String? error,
  }) {
    return CancelOrderState(
      isLoading: isLoading ?? this.isLoading,
      cancelledOrderId: cancelledOrderId,
      error: error,
    );
  }
}

class CancelOrderNotifier extends StateNotifier<CancelOrderState> {
  final OrderService _orderService;

  CancelOrderNotifier(this._orderService) : super(const CancelOrderState());

  Future<bool> cancelOrder(String orderId) async {
    print('CancelOrderProvider: Starting cancel process for order $orderId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('CancelOrderProvider: Calling order service...');
      await _orderService.cancelOrder(orderId);
      print('CancelOrderProvider: Order canceled successfully');
      state = state.copyWith(
        isLoading: false,
        cancelledOrderId: orderId,
      );
      return true;
    } catch (e) {
      print('CancelOrderProvider: Error canceling order: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const CancelOrderState();
  }
}

final cancelOrderProvider = StateNotifierProvider<CancelOrderNotifier, CancelOrderState>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return CancelOrderNotifier(orderService);
});

// Provider para verificar si un pedido se puede cancelar
final canCancelOrderProvider = ProviderFamily<bool, Order>((ref, order) {
  final orderService = ref.read(orderServiceProvider);
  return orderService.canCancelOrder(order);
});
