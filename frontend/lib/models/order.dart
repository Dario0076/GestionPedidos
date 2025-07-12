import 'user.dart';
import 'product.dart';

enum OrderStatus {
  pending('PENDING', 'Pendiente'),
  confirmed('CONFIRMED', 'Confirmado'),
  preparing('PREPARING', 'Preparando'),
  shipped('SHIPPED', 'Enviado'),
  delivered('DELIVERED', 'Entregado'),
  cancelled('CANCELLED', 'Cancelado');

  const OrderStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final User? user;
  final List<OrderDetail> orderDetails;

  const Order({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.total,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.user,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      orderDate: DateTime.parse(
        json['orderDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      status: OrderStatus.fromString(json['status'] as String? ?? 'PENDING'),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      userId: json['userId'] as String? ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      orderDetails: (json['orderDetails'] as List? ?? [])
          .map((detail) => OrderDetail.fromJson(detail))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'status': status.value,
      'total': total,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      if (user != null) 'user': user!.toJson(),
      'orderDetails': orderDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  Order copyWith({
    String? id,
    DateTime? orderDate,
    OrderStatus? status,
    double? total,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    User? user,
    List<OrderDetail>? orderDetails,
  }) {
    return Order(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  // Método para calcular el total de items en el pedido
  int get totalItems {
    return orderDetails.fold(0, (sum, detail) => sum + detail.quantity);
  }

  @override
  String toString() {
    return 'Order(id: $id, status: ${status.displayName}, total: \$${total.toStringAsFixed(2)}, items: $totalItems)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class OrderDetail {
  final String id;
  final int quantity;
  final double price;
  final double subtotal;
  final String orderId;
  final String productId;
  final Product? product;

  const OrderDetail({
    required this.id,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.orderId,
    required this.productId,
    this.product,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'orderId': orderId,
      'productId': productId,
      if (product != null) 'product': product!.toJson(),
    };
  }

  OrderDetail copyWith({
    String? id,
    int? quantity,
    double? price,
    double? subtotal,
    String? orderId,
    String? productId,
    Product? product,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'OrderDetail(productId: $productId, quantity: $quantity, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Clase para crear nuevos pedidos
class CreateOrderRequest {
  final List<OrderDetailRequest> orderItems;
  final String? notes;

  const CreateOrderRequest({required this.orderItems, this.notes});

  Map<String, dynamic> toJson() {
    return {
      'orderItems': orderItems.map((detail) => detail.toJson()).toList(),
      'notes': notes,
    };
  }
}

class OrderDetailRequest {
  final String productId;
  final int quantity;

  const OrderDetailRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}
