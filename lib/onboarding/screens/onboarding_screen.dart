import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/onboarding_service.dart';
import '../../services/config_service.dart';
import '../../webview/webview_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  OnboardingService get _service => OnboardingService();
  
  @override
  Widget build(BuildContext context) {
    // Config should be loaded by now
    final config = _service.config;
    final steps = config.steps;
    final colors = config.settings;

    return Scaffold(
      body: Stack(
        children: [
          // Background Color (Global)
          Container(color: Colors.white),

          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: steps.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildStep(steps[index], config);
            },
          ),

          // Navigation Overlay (Dots + Buttons)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(config, steps.length),
          ),
          
          // Skip Button (Top Right) -> Only if configured
          if (colors.showSkip && _currentPage < steps.length - 1)
             Positioned(
               top: MediaQuery.of(context).padding.top + 10,
               right: 20,
               child: TextButton(
                 onPressed: _finishOnboarding,
                 child: Text(
                   'Skip',
                   style: TextStyle(
                     color: config.style == 'fullscreen' ? Colors.white : Colors.grey,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildStep(dynamic step, dynamic config) {
    if (config.style == 'fullscreen') {
      return _buildFullscreenStep(step, config);
    } else if (config.style == 'card') {
      return _buildCardStep(step, config);
    } else {
      return _buildMinimalStep(step, config);
    }
  }

  // --- Layouts ---

  Widget _buildFullscreenStep(dynamic step, dynamic config) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        if (step.imageUrl.isNotEmpty)
          Image.network(
            step.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator(color: config.settings.primaryColor));
            },
             errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
          ),
        
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: config.settings.overlayOpacity),
              ],
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: config.settings.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: config.settings.textColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardStep(dynamic step, dynamic config) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (step.imageUrl.isNotEmpty)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        step.imageUrl,
                        fit: BoxFit.cover,
                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalStep(dynamic step, dynamic config) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            if (step.imageUrl.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: config.settings.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(24),
                   child: Image.network(
                      step.imageUrl,
                      height: 320,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 320, 
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: Icon(Icons.image, size: 64, color: Colors.grey.shade300),
                      ),
                   )
                ),
              ),
            const Spacer(flex: 3),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- Bottom Bar ---

  Widget _buildBottomBar(dynamic config, int totalSteps) {
    final isLastPage = _currentPage == totalSteps - 1;
    final primaryColor = config.settings.primaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots
          Row(
            children: List.generate(totalSteps, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? primaryColor 
                      : primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next/Finish Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 56,
            child: ElevatedButton(
              onPressed: isLastPage ? _finishOnboarding : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              ),
              child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     isLastPage ? 'Get Started' : 'Next',
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const SizedBox(width: 12),
                   Icon(isLastPage ? Icons.rocket_launch : Icons.arrow_forward_rounded, size: 20)
                 ]
              ),
            ),
          )
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() async {
    await _service.markAsSeen();
    
    if (mounted) {
       // Navigate to Home
       // We use Navigator.pushReplacement to kill the back stack
       final configService = context.read<ConfigService>();
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (_) => WebViewScreen(config: configService.config)),
       );
    }
  }
}
