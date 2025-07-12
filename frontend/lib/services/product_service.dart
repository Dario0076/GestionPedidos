import '../models/product.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _apiService = ApiService();

  // Obtener todos los productos con filtros opcionales
  Future<List<Product>> getProducts({
    String? categoryId,
    String? search,
  }) async {
    try {
      print('ProductService: Getting products...');
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      print('ProductService: Making request to ${ApiConstants.products}');
      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      print('ProductService: Response received with status ${response.statusCode}');
      print('ProductService: Response data type: ${response.data.runtimeType}');
      
      final data = response.data as List;
      print('ProductService: Found ${data.length} products');
      print('ProductService: First product data: ${data.isNotEmpty ? data[0] : "No products"}');
      
      final products = <Product>[];
      for (int i = 0; i < data.length; i++) {
        try {
          print('ProductService: Processing product $i: ${data[i]['name']}');
          final product = Product.fromJson(data[i]);
          products.add(product);
          print('ProductService: Successfully parsed product: ${product.name}');
        } catch (e) {
          print('ProductService: Error parsing product $i: $e');
          print('ProductService: Product data: ${data[i]}');
          rethrow;
        }
      }
      
      print('ProductService: Successfully parsed ${products.length} products');
      
      return products;
    } on ApiException catch (e) {
      print('ProductService: ApiException - ${e.message}');
      rethrow;
    } catch (e) {
      print('ProductService: Unexpected error - $e');
      throw ApiException(message: 'Error al cargar productos');
    }
  }

  // Obtener un producto por ID
  Future<Product> getProduct(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.productById(id),
      );

      return Product.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar el producto');
    }
  }

  // Obtener todas las categorías
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.categories);

      final data = response.data as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar categorías');
    }
  }

  // Obtener una categoría por ID con sus productos
  Future<Category> getCategory(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.categoryById(id),
      );

      return Category.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar la categoría');
    }
  }

  // Buscar productos por nombre o descripción
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return getProducts(search: query);
  }

  // Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return getProducts(categoryId: categoryId);
  }

  // Obtener productos destacados (los más recientes o con más stock)
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final products = await getProducts();
      
      // Ordenar por fecha de creación (más recientes primero) y limitar
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products.take(limit).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error al cargar productos destacados');
    }
  }

  // Verificar disponibilidad de stock
  Future<bool> checkStock(String productId, int quantity) async {
    try {
      final product = await getProduct(productId);
      return product.stock >= quantity;
    } catch (e) {
      return false;
    }
  }
}
