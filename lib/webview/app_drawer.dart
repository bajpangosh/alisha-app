import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';
import '../config/menu_item.dart';
import '../services/config_service.dart';

class AppDrawer extends StatelessWidget {
  final WebViewController controller;

  const AppDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Watch config so if it updates (e.g. from API), layout updates
    final config = context.watch<ConfigService>().config;

    // Material 3 Navigation Drawer
    return NavigationDrawer(
      onDestinationSelected: (int index) {
        // Handle selection
        // Since NavigationDrawerDestination corresponds to an index, we need to map back to our menu items.
        // We have a header, then menu items, then divider, then share.
        // Wait, onDestinationSelected only fires for destinations (items).
        // So index 0 is the first item.
        
        if (index < config.drawerMenu.length) {
          Navigator.pop(context); // Close drawer
          _handleMenuAction(context, config.drawerMenu[index]);
        } else {
           // This is the Share or other static items added at the end
           final shareIndex = index - config.drawerMenu.length;
           if (shareIndex == 0) {
             Navigator.pop(context);
             _handleMenuAction(context, MenuItem(label: 'Share', icon: 'share', action: 'share', value: ''));
           }
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: config.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                 child: Icon(Icons.auto_awesome, color: config.primaryColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                config.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Powered by ${config.developerName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: Divider(),
        ),
        
        ...config.drawerMenu.map((item) {
          return NavigationDrawerDestination(
            icon: Icon(_getIconData(item.icon)),
            label: Text(item.label),
          );
        }),
        
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Divider(),
        ),
        
        const NavigationDrawerDestination(
          icon: Icon(Icons.share),
          label: Text('Share App'),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, MenuItem item) {
    return ListTile(
      leading: Icon(_getIconData(item.icon)),
      title: Text(item.label),
      onTap: () async {
        Navigator.pop(context); // Close drawer
        await _handleMenuAction(context, item);
      },
    );
  }

  Future<void> _handleMenuAction(BuildContext context, MenuItem item) async {
    if (item.action == 'url') {
      if (item.value.startsWith('http')) {
        controller.loadRequest(Uri.parse(item.value));
      } else {
        // Handle relative URLs if any, or internal pages
      }
    } else if (item.action == 'external') {
      final uri = Uri.parse(item.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (item.action == 'share') {
       // Placeholder for share
       print('Share action triggered');
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'info':
        return Icons.info;
      case 'contact_support':
        return Icons.contact_support;
      case 'privacy_tip':
        return Icons.privacy_tip;
      case 'list_alt':
        return Icons.list_alt;
      case 'share':
        return Icons.share;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.article;
    }
  }
}
