import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  bool _isNavigating = false; // Prevent multiple navigation

  @override
  void initState() {
    super.initState();
    _initializeSystemUI();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeSystemUI() {
    // Set status bar style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Enable edge-to-edge
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Text animations with better easing
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation with smooth curve
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));
  }

  Future<void> _startAnimationSequence() async {
    try {
      // Start logo animation
      await _logoController.forward();

      // Start text animation after logo
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _textController.forward();
      }

      // Start progress animation
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _progressController.forward();
      }

      // Navigate to home after animations complete
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted && !_isNavigating) {
        _navigateToHome();
      }
    } catch (e) {
      // Handle any animation errors gracefully
      debugPrint('Animation error: $e');
      if (mounted && !_isNavigating) {
        _navigateToHome();
      }
    }
  }

  void _navigateToHome() {
    if (!_isNavigating && mounted) {
      _isNavigating = true;

      // Reset system UI to normal state before navigation
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);

      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bluePrimary, // Fallback color
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bluePrimary,
              AppColors.blueDark,
              AppColors.darkestBlue,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Animation
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: ScaleTransition(
                                scale: _logoScaleAnimation,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: AppColors.bluePrimary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.bluePrimary,
                                            AppColors.darkestBlue,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.electric_bolt,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Text Animation with improved typography
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: SlideTransition(
                                position: _textSlideAnimation,
                                child: Column(
                                  children: [
                                    Text(
                                      'ELECON',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ) ?? const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 80,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Electric Consumption Controller',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w300,
                                      ) ?? const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sistem Monitoring Listrik Kampus',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        color: Colors.white60,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w300,
                                      ) ?? const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white60,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Progress Indicator with improved design
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Container(
                                width: 200,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 100),
                                      width: 200 * _progressAnimation.value,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white70,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              FadeTransition(
                                opacity: _progressAnimation,
                                child: Text(
                                  'Memuat aplikasi...',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ) ?? const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
