import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';
import '../config/menu_item.dart';

import 'app_drawer.dart';
import 'app_bottom_nav.dart';

class WebViewScreen extends StatefulWidget {
  final AppConfig config;
  const WebViewScreen({super.key, required this.config});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}



class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasLoadError = false;
  int _drawerSelectedIndex = 0;
  int _bottomSelectedIndex = 0;
  double _progress = 0;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.config.baseWebUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasLoadError = false;
              _currentUrl = url;
            });
            _syncSelectedMenus(url);
          },
          onPageFinished: (String url) {
             setState(() {
               _isLoading = false;
               _progress = 1;
               _currentUrl = url;
             });
             _syncSelectedMenus(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasLoadError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.config.baseWebUrl));
    _showFirstRunHint();
  }

  Future<void> _showFirstRunHint() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'alisha_menu_hint_seen';
    if (prefs.getBool(key) == true || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tip: Open the drawer for full menu. Use bottom shortcuts for quick access.'),
          duration: Duration(seconds: 4),
        ),
      );
    });
    await prefs.setBool(key, true);
  }

  void _syncSelectedMenus(String url) {
    final drawerIndex = _matchMenuIndex(widget.config.drawerMenu, url);
    final footerIndex = _matchMenuIndex(widget.config.footerMenu, url);

    if (drawerIndex != _drawerSelectedIndex || footerIndex != _bottomSelectedIndex) {
      setState(() {
        if (drawerIndex >= 0) _drawerSelectedIndex = drawerIndex;
        if (footerIndex >= 0) _bottomSelectedIndex = footerIndex;
      });
    }
  }

  int _matchMenuIndex(List<MenuItem> items, String currentUrl) {
    if (items.isEmpty) return -1;
    final current = Uri.tryParse(currentUrl);
    if (current == null) return -1;

    for (var i = 0; i < items.length; i++) {
      final itemUri = _resolveUri(items[i].value, widget.config.baseWebUrl);
      if (itemUri == null) continue;
      final sameHost = itemUri.host.isNotEmpty && itemUri.host == current.host;
      final samePath = itemUri.path.isNotEmpty && itemUri.path == current.path;
      if (sameHost && samePath) return i;
    }
    return -1;
  }

  Uri? _resolveUri(String rawValue, String baseWebUrl) {
    final value = rawValue.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Uri.tryParse(value);
    }
    if (value.startsWith('/')) {
      return Uri.tryParse(baseWebUrl)?.resolve(value);
    }
    return Uri.tryParse('https://$value');
  }

  Future<void> _showQuickActions() async {
    final quickItems = widget.config.footerMenu.isNotEmpty
        ? widget.config.footerMenu.take(4).toList()
        : widget.config.drawerMenu.take(4).toList();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(ctx);
                  _controller.loadRequest(Uri.parse(widget.config.baseWebUrl));
                },
              ),
              ...quickItems.asMap().entries.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.arrow_outward_rounded),
                  title: Text(entry.value.label),
                  onTap: () {
                    Navigator.pop(ctx);
                    final uri = _resolveUri(entry.value.value, widget.config.baseWebUrl);
                    if (uri != null) {
                      _controller.loadRequest(uri);
                    }
                  },
                );
              }),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Refresh'),
                onTap: () {
                  Navigator.pop(ctx);
                  _controller.reload();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should use dark or light app bar based on primary color brightness or design choice.
    // For "Minimal, Clean", a white app bar with black text is often best, or simple primary color.
    // Let's go with a clean white app bar if possible, or primary if it's a strong brand.
    // But let's stick to the config preferences while upgrading the look.
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 8,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.config.appName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          )
        ],
      ),
      drawer: widget.config.drawerMenuEnabled
          ? AppDrawer(
              controller: _controller,
              selectedIndex: _drawerSelectedIndex,
              onSelected: (index) {
                setState(() {
                  _drawerSelectedIndex = index;
                });
              },
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
             WebViewWidget(controller: _controller),
             
             // Top Linear Progress for "Fast Perception"
             if (_isLoading)
               Positioned(
                 top: 0,
                 left: 0,
                 right: 0,
              child: LinearProgressIndicator(
                   color: widget.config.secondaryColor,
                    backgroundColor: Colors.transparent,
                   minHeight: 4,
                   value: _progress > 0 && _progress < 1 ? _progress : null,
                 ),
               ),
             if (_hasLoadError)
               Center(
                 child: Container(
                   margin: const EdgeInsets.all(24),
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(16),
                     boxShadow: const [
                       BoxShadow(
                         blurRadius: 24,
                         color: Color(0x14000000),
                         offset: Offset(0, 8),
                       ),
                     ],
                   ),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.wifi_off_rounded, size: 42),
                       const SizedBox(height: 12),
                       const Text(
                         'Could not load page',
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                       ),
                       const SizedBox(height: 6),
                       Text(
                         _currentUrl,
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                         style: const TextStyle(color: Colors.black54),
                       ),
                       const SizedBox(height: 14),
                       FilledButton.icon(
                         onPressed: () {
                           setState(() {
                             _hasLoadError = false;
                           });
                           _controller.reload();
                         },
                         icon: const Icon(Icons.refresh_rounded),
                         label: const Text('Retry'),
                       ),
                     ],
                   ),
                 ),
               ),
          ],
        ),
      ),
      bottomNavigationBar: widget.config.footerMenuEnabled
          ? AppBottomNav(
              controller: _controller,
              selectedIndex: _bottomSelectedIndex,
              currentUrl: _currentUrl,
              onSelected: (index) {
                setState(() {
                  _bottomSelectedIndex = index;
                });
              },
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        child: const Icon(Icons.tune_rounded),
      ),
    );
  }
}
