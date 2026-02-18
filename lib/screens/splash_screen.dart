import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../onboarding/services/onboarding_service.dart';
import '../webview/webview_screen.dart';
import '../onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
       duration: const Duration(milliseconds: 1500),
       vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
     _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
    _checkApp();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkApp() async {
    // 1. Get Services
    final configService = context.read<ConfigService>();
    final onboardingService = OnboardingService();

    // 2. Initialize Onboarding (Load Cache)
    await onboardingService.init();

    // 3. Try to fetch fresh config (with minimal wait to show animation)
    final minWait = Future.delayed(const Duration(seconds: 2));
    final fetchTask = onboardingService.fetchConfig(configService.config.apiBaseUrl).timeout(
         const Duration(seconds: 3), 
         onTimeout: () {},
    );

    await Future.wait([minWait, fetchTask]);


    // 4. Decide where to go
    if (!mounted) return;

    final shouldShow = await onboardingService.shouldShowOnboarding();
    if (!mounted) return;

    if (shouldShow) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_,__,___) => const OnboardingScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_,__,___) => WebViewScreen(config: configService.config),
           transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<ConfigService>().config;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 // App Logo or Name
                 Container(
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: config.primaryColor.withValues(alpha: 0.1),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(
                     Icons.auto_awesome, 
                     size: 64, 
                     color: config.primaryColor
                   ),
                 ),
                 const SizedBox(height: 24),
                 Text(
                   config.appName,
                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
                     color: config.primaryColor,
                     fontWeight: FontWeight.w800,
                     letterSpacing: -0.5,
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'Premium Mobile Experience', 
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
                 const SizedBox(height: 48),
                 SizedBox(
                   width: 48, 
                   height: 48, 
                   child: CircularProgressIndicator(
                     color: config.secondaryColor, 
                     strokeWidth: 3
                   )
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
