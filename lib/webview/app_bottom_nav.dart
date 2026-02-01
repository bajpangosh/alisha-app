import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/menu_item.dart';
import '../services/config_service.dart';

class AppBottomNav extends StatelessWidget {
  final WebViewController controller;

  const AppBottomNav({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigService>().config;

    if (config.footerMenu.isEmpty) {
      return const SizedBox.shrink();
    }

    // BottomNavigationBar supports max 5 items usually, and structure expects strict index.
    // We will use a Row for custom flexibility if items > 5 or just mapping 0..Min(items.length, 5)
    
    // For simplicity and standard UI, let's use NavigationBar
    // Material 3 NavigationBar is taller and has cleaner interaction.
    final displayItems = config.footerMenu.take(5).toList();

    return NavigationBar(
      selectedIndex: 0, // We don't track state deeply for web view navigation here
      onDestinationSelected: (index) {
        _handleMenuAction(context, displayItems[index]);
      },
      destinations: displayItems.map((item) {
        return NavigationDestination(
          icon: Icon(_getIconData(item.icon)),
          label: item.label,
        );
      }).toList(),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, MenuItem item) async {
    if (item.action == 'url') {
      if (item.value.startsWith('http')) {
        controller.loadRequest(Uri.parse(item.value));
      }
    } else if (item.action == 'external') {
      final uri = Uri.parse(item.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
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
      case 'person':
        return Icons.person;
      case 'shopping_cart':
        return Icons.shopping_cart;
      default:
        return Icons.circle;
    }
  }
}
