import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/connection_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../widgets/translated_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
      // Verificar conexión API
      ref.read(connectionProvider.notifier).checkConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final productState = ref.watch(productProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              'Hola ${authState.user?.name ?? 'Usuario'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            TranslatedText(
              '¿Qué necesitas hoy?',
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Indicador de estado de conexión API
          const ConnectionStatusWidget(),

          // Selector de idioma
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSelector(showName: false),
          ),

          // Botón de configuración
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),

          // Carrito
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                onPressed: () => context.go('/cart'),
              ),
              if (cartState.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartState.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Menú
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onSelected: (value) {
              switch (value) {
                case 'admin':
                  context.go('/admin');
                  break;
                case 'orders':
                  context.go('/orders');
                  break;
                case 'profile':
                  context.go('/profile');
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (authState.user?.role == 'ADMIN') ...[
                const PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                    leading: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.purple,
                    ),
                    title: TranslatedText(
                      'Panel Admin',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
              ],
              const PopupMenuItem(
                value: 'orders',
                child: ListTile(
                  leading: Icon(Icons.receipt_long),
                  title: TranslatedText('Mis Pedidos'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: TranslatedText('Perfil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: TranslatedText(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardTheme.color,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filtros de categoría
          if (productState.categories.isNotEmpty)
            Container(
              height: 50,
              color: Theme.of(context).cardTheme.color,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productState.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const TranslatedText('Todos'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          setState(() => _selectedCategoryId = null);
                        },
                      ),
                    );
                  }

                  final category = productState.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: TranslatedText(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

          // Lista de productos
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        TranslatedText(
                          'Error: ${productState.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(productProvider.notifier).loadProducts();
                          },
                          child: const TranslatedText('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final productState = ref.watch(productProvider);

    // Filtrar productos
    var filteredProducts = productState.products.where((product) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      bool matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            TranslatedText(
              'No se encontraron productos',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductListItem(product);
      },
    );
  }

  Widget _buildProductListItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.description != null) ...[
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                TranslatedText(
                  'Stock: ${product.stock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: product.stock > 0
                      ? () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: TranslatedText(
                                '${product.name} agregado al carrito',
                              ),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Ver carrito',
                                onPressed: () => context.go('/cart'),
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const TranslatedText('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Cerrar Sesión'),
        content: const TranslatedText(
          '¿Estás seguro de que quieres cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const TranslatedText('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
