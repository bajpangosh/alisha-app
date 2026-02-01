import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
             setState(() {
               _isLoading = false;
             });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.config.baseWebUrl));
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
        title: Text(
          widget.config.appName, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Add a reload button for "Fast" perception control
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          )
        ],
      ),
      drawer: widget.config.drawerMenuEnabled ? AppDrawer(controller: _controller) : null,
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
                 ),
               ),
          ],
        ),
      ),
      bottomNavigationBar: widget.config.footerMenuEnabled ? AppBottomNav(controller: _controller) : null,
    );
  }
}
