import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/vector_illustrations.dart';
import '../../widgets/device_selector_modal.dart';
import '../main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Spot Risk Before It Becomes Damage.',
      'subtitle':
          'Assess database updates, permission escalations, and system changes before they break production.',
      'illustration': const GuardianIllustration(width: 250, height: 180),
      'color': AppTheme.pastelBlue,
    },
    {
      'title': 'Understand What Went Wrong.',
      'subtitle':
          'Automated root cause diagnostics connect errors back to recent changes so you never guess blindly.',
      'illustration': const InvestigationIllustration(width: 250, height: 180),
      'color': AppTheme.pastelPurple,
    },
    {
      'title': 'Recover Safely. Verify Everything.',
      'subtitle':
          'Restore verified safe configurations with 1-tap automated health checks that confirm service integrity.',
      'illustration': const RecoveryIllustration(width: 250, height: 180),
      'color': AppTheme.pastelMint,
    },
  ];

  Future<void> _onGetStarted() async {
    // Open the Brand -> Model selection popup as requested
    await DeviceSelectorModal.show(context);

    if (!mounted) return;

    // Ensure selected device is populated (defaults to Samsung Galaxy S24 if dismissed)
    final appState = context.read<AppStateProvider>();
    if (appState.selectedDevice == null) {
      await appState.setSelectedDevice('Samsung', 'Galaxy S24');
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Top skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onGetStarted,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        item['illustration'] as Widget,
                        const SizedBox(height: 36),

                        // Title
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          item['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom indicators & CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppTheme.lilacDark : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _onGetStarted();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pastelPurple,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
