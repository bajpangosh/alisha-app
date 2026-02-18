import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/menu_item.dart';
import '../services/config_service.dart';

class AppDrawer extends StatelessWidget {
  final WebViewController controller;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const AppDrawer({
    super.key,
    required this.controller,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigService>().config;
    final menuItems = config.drawerMenu;

    return Drawer(
      width: 320,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, config.appName, config.developerName, config.primaryColor),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Navigation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isSelected = index == selectedIndex;

                  return _ModernMenuTile(
                    icon: _getIconData(item.icon),
                    title: item.label,
                    selected: isSelected,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      onSelected?.call(index);
                      await _handleMenuAction(context, item);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _ModernMenuTile(
                icon: Icons.share_rounded,
                title: 'Share App',
                selected: false,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  await _handleMenuAction(
                    context,
                    MenuItem(label: 'Share', icon: 'share', action: 'share', value: ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String appName,
    String developerName,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'by $developerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'contact_support':
        return Icons.contact_support_rounded;
      case 'privacy_tip':
        return Icons.privacy_tip_rounded;
      case 'list_alt':
        return Icons.list_alt_rounded;
      case 'share':
        return Icons.share_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}

class _ModernMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ModernMenuTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent;
    final fgColor = selected ? Theme.of(context).colorScheme.primary : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bgColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                  color: fgColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: fgColor.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
