import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/menu_item.dart';
import '../services/config_service.dart';

class AppBottomNav extends StatelessWidget {
  final WebViewController controller;
  final int selectedIndex;
  final String currentUrl;
  final ValueChanged<int>? onSelected;

  const AppBottomNav({
    super.key,
    required this.controller,
    this.selectedIndex = 0,
    this.currentUrl = '',
    this.onSelected,
  });

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

    final safeSelectedIndex = selectedIndex.clamp(0, displayItems.length - 1);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        elevation: 12,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
      selectedIndex: safeSelectedIndex,
      onDestinationSelected: (index) {
        HapticFeedback.lightImpact();
        onSelected?.call(index);
        _handleMenuAction(context, displayItems[index]);
      },
      destinations: displayItems.map((item) {
        return NavigationDestination(
          icon: Icon(_getIconData(item.icon), size: 22),
          selectedIcon: Icon(_getIconData(item.icon), size: 24),
          label: item.label,
        );
      }).toList(),
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, MenuItem item) async {
    final config = context.read<ConfigService>().config;
    final action = item.action.trim().isEmpty ? 'url' : item.action.trim();

    if (action == 'url') {
      final uri = _resolveUri(item.value, config.baseWebUrl);
      if (uri != null) {
        controller.loadRequest(uri);
      }
    } else if (action == 'external') {
      final uri = _resolveUri(item.value, config.baseWebUrl);
      if (uri != null && await _confirmExternalNavigation(context, uri) && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (action == 'share') {
      final shareUrl = config.baseWebUrl.trim().isEmpty ? item.value.trim() : config.baseWebUrl.trim();
      final text = shareUrl.isEmpty ? config.appName : '${config.appName}\n$shareUrl';
      await Share.share(text);
    }
  }

  Future<bool> _confirmExternalNavigation(BuildContext context, Uri uri) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Open External Link?'),
          content: Text(uri.host.isEmpty ? uri.toString() : uri.host),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open')),
          ],
        );
      },
    );
    return result ?? false;
  }

  Uri? _resolveUri(String rawValue, String baseWebUrl) {
    final value = rawValue.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Uri.tryParse(value);
    }

    if (value.startsWith('/')) {
      final base = Uri.tryParse(baseWebUrl);
      return base?.resolve(value);
    }

    return Uri.tryParse('https://$value');
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
