import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/translated_text.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const TranslatedText(
          'Mi Perfil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Información del usuario
                  _buildUserInfoCard(context, user),

                  const SizedBox(height: 16),

                  // Opciones del perfil
                  _buildProfileOptions(context, ref),

                  const SizedBox(height: 16),

                  // Configuración
                  _buildSettingsCard(context, ref),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nombre
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Email
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Información adicional
            if (user.phone?.isNotEmpty ?? false) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    user.phone!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (user.address?.isNotEmpty ?? false) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.address!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.edit,
            title: 'Editar Perfil',
            subtitle: 'Actualizar información personal',
            onTap: () => _showEditProfile(context, ref),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.receipt_long,
            title: 'Mis Pedidos',
            subtitle: 'Ver historial de pedidos',
            onTap: () => context.go('/orders'),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.shopping_cart,
            title: 'Mi Carrito',
            subtitle: 'Ver productos en el carrito',
            onTap: () => context.go('/cart'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Tema, idioma y accesibilidad',
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            subtitle: 'Obtener asistencia',
            onTap: () => _showHelpDialog(context),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Información de la aplicación',
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de la aplicación',
            onTap: () => _showLogoutDialog(context, ref),
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: TranslatedText(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: TranslatedText(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    // TODO: Implementar edición de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: TranslatedText('Función de edición de perfil en desarrollo'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Ayuda y Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText('¿Necesitas ayuda?'),
            SizedBox(height: 8),
            TranslatedText('• Email: soporte@gestionpedidos.com'),
            TranslatedText('• Teléfono: +1 (555) 123-4567'),
            TranslatedText('• Horario: Lun-Vie 9:00-18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Gestión de Pedidos',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.shopping_cart,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: const [
        TranslatedText('Aplicación móvil para la gestión integral de pedidos.'),
        SizedBox(height: 8),
        TranslatedText('Desarrollada con Flutter para Android.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
            child: const TranslatedText(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
