import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/translated_text.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Verificar que el usuario sea administrador
    if (authState.user?.role != 'ADMIN') {
      return Scaffold(
        appBar: AppBar(title: const TranslatedText('Acceso Denegado')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              TranslatedText(
                'No tienes permisos para acceder a esta sección',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings),
            SizedBox(width: 8),
            TranslatedText(
              'Panel de Administración',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildAdminCard(
              context,
              icon: Icons.inventory_2,
              title: 'Gestionar\nProductos',
              subtitle: 'CRUD de productos',
              color: Colors.blue,
              onTap: () => context.go('/admin/products'),
            ),
            _buildAdminCard(
              context,
              icon: Icons.category,
              title: 'Gestionar\nCategorías',
              subtitle: 'CRUD de categorías',
              color: Colors.green,
              onTap: () => context.go('/admin/categories'),
            ),
            _buildAdminCard(
              context,
              icon: Icons.people,
              title: 'Gestionar\nUsuarios',
              subtitle: 'CRUD de usuarios',
              color: Colors.orange,
              onTap: () => context.go('/admin/users'),
            ),
            _buildAdminCard(
              context,
              icon: Icons.assignment,
              title: 'Gestionar\nPedidos',
              subtitle: 'Actualizar estados',
              color: Colors.purple,
              onTap: () => context.go('/admin/orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              TranslatedText(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              TranslatedText(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
