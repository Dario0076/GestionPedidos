import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

// Provider para el servicio de productos
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Estado de productos
class ProductState {
  final bool isLoading;
  final List<Product> products;
  final List<Category> categories;
  final String? error;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.categories = const [],
    this.error,
  });

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    List<Category>? categories,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}

// Notifier para productos
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _productService;

  ProductNotifier(this._productService) : super(const ProductState());

  Future<void> loadProducts() async {
    print('ProductProvider: Starting to load products...');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('ProductProvider: Calling product service...');
      final products = await _productService.getProducts();
      final categories = await _productService.getCategories();
      
      print('ProductProvider: Successfully loaded ${products.length} products and ${categories.length} categories');
      state = state.copyWith(
        isLoading: false,
        products: products,
        categories: categories,
      );
    } catch (e) {
      print('ProductProvider: Error loading products - $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final products = await _productService.getProductsByCategory(categoryId);
      
      state = state.copyWith(
        isLoading: false,
        products: products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final products = await _productService.searchProducts(query);
      
      state = state.copyWith(
        isLoading: false,
        products: products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider principal para productos
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productService = ref.read(productServiceProvider);
  return ProductNotifier(productService);
});

// Provider para todas las categorías (mantenido para compatibilidad)
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return productService.getCategories();
});

// Provider para todos los productos (mantenido para compatibilidad)
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return productService.getProducts();
});

// Provider para un producto específico
final singleProductProvider = FutureProviderFamily<Product, String>((ref, productId) async {
  final productService = ref.read(productServiceProvider);
  return productService.getProduct(productId);
});

// Provider para búsqueda de productos
class SearchState {
  final String query;
  final List<Product> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Product>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProductService _productService;

  SearchNotifier(this._productService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: query,
      isLoading: true,
      error: null,
    );

    try {
      final results = await _productService.searchProducts(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        results: [],
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final productService = ref.read(productServiceProvider);
  return SearchNotifier(productService);
});

// Provider para filtros de productos
class ProductFilters {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStock;

  const ProductFilters({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.inStock,
  });

  ProductFilters copyWith({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) {
    return ProductFilters(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
    );
  }

  bool get hasFilters => 
    categoryId != null || 
    minPrice != null || 
    maxPrice != null || 
    inStock != null;
}

class ProductFiltersNotifier extends StateNotifier<ProductFilters> {
  ProductFiltersNotifier() : super(const ProductFilters());

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void setInStock(bool? inStock) {
    state = state.copyWith(inStock: inStock);
  }

  void clearFilters() {
    state = const ProductFilters();
  }
}

final productFiltersProvider = StateNotifierProvider<ProductFiltersNotifier, ProductFilters>((ref) {
  return ProductFiltersNotifier();
});

// Provider para productos filtrados
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final filters = ref.watch(productFiltersProvider);
  final productService = ref.read(productServiceProvider);
  
  List<Product> products;
  
  if (filters.categoryId != null) {
    products = await productService.getProductsByCategory(filters.categoryId!);
  } else {
    products = await productService.getProducts();
  }
  
  // Aplicar filtros adicionales
  if (filters.minPrice != null) {
    products = products.where((p) => p.price >= filters.minPrice!).toList();
  }
  
  if (filters.maxPrice != null) {
    products = products.where((p) => p.price <= filters.maxPrice!).toList();
  }
  
  if (filters.inStock == true) {
    products = products.where((p) => p.stock > 0).toList();
  }
  
  return products;
});
