import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/features/onboarding/providers/onboarding_provider.dart';
import 'package:bookbank/Widgets/navigation_bar.dart';
import 'package:bookbank/features/setting/widgets/privacy_policy_dialog.dart';
import 'onboarding_page_2.dart';

// ─── Onboarding Wrapper ───────────────────────────────────────────────────────
// Decides whether to show Onboarding or the main app

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    // While loading preference from SharedPreferences, show a blank screen
    if (!onboarding.isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(),
      );
    }

    if (onboarding.isCompleted) {
      return const HomePage();
    }

    return const OnboardingPage1();
  }
}

class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _logoScaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingPage2(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();
    final lang = locProvider.language;
    final loc = locProvider.loc;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ──────────────────────────────────────────────
          // Progressive blur background — top is sharp, bottom is heavily blurred
          _ProgressiveBlurBackground(
            imagePath: 'lib/core/images/Background_Onbording2.jpeg',
          ),

          // ── Dark Overlay ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Name
                      Text(
                        'BookBank',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Language Button
                      _LanguagePill(lang: lang, locProvider: locProvider),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Logo + Text
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        // Logo
                        ScaleTransition(
                          scale: _logoScaleAnim,
                          child: Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.w),
                              child: Image.asset(
                                'lib/core/icons/BookBank_Logo 1.png',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // Welcome Title
                        Text(
                          loc.welcomeTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            loc.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.sp,
                              height: 1.6,
                            ),
                          ),
                        ),

                        SizedBox(height: 60.h),
                      ],
                    ),
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      // Next Button
                      _OnboardingButton(label: loc.next, onTap: _goToNextPage),

                      SizedBox(height: 16.h),

                      // Privacy Policy
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => PrivacyPolicyDialog(),
                          );
                        },
                        child: Text(
                          loc.privacyPolicy,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12.sp,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progressive Blur Background ─────────────────────────────────────────────
//
// Creates an iOS-style progressive blur: the top of the image is crisp,
// and blur intensity increases quadratically toward the bottom.
// Implementation: stack the source image, then overlay N semi-transparent
// BackdropFilter slices that each blur only their respective vertical band.

class _ProgressiveBlurBackground extends StatelessWidget {
  final String imagePath;

  const _ProgressiveBlurBackground({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Number of blur slices — more slices = smoother gradient, fewer banding artifacts
    const int steps = 20;

    // Maximum blur at the bottom
    const double maxSigma = 24.0;

    // The blur starts at this fraction from the top (0 = very top)
    const double blurStartFraction = 0.30;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Source image (always rendered in full, unblurred) ──────────────
        Image.asset(imagePath, fit: BoxFit.cover),

        // ── Progressive blur slices ────────────────────────────────────────
        // Each slice covers a thin horizontal band and applies a BackdropFilter.
        // The blur sigma grows quadratically so the lower slices are much blurrier.
        LayoutBuilder(
          builder: (context, constraints) {
            final totalH = constraints.maxHeight;
            final sliceH = totalH / steps;

            return Stack(
              children: List.generate(steps, (i) {
                // Progress t goes from 0 (top slice) → 1 (bottom slice)
                final t = i / (steps - 1);

                // Only start blurring after blurStartFraction
                final effective = ((t - blurStartFraction) /
                        (1.0 - blurStartFraction))
                    .clamp(0.0, 1.0);

                // Cubic ease-in: slower build-up in the middle, heavy blur only at bottom
                final sigma = maxSigma * effective * effective * effective;

                final top = i * sliceH;

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  height: sliceH + 1, // +1 to avoid hairline gaps
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: sigma,
                        sigmaY: sigma,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

// ─── Language Pill ────────────────────────────────────────────────────────────

class _LanguagePill extends StatelessWidget {
  final AppLanguage lang;
  final LocalizationProvider locProvider;

  const _LanguagePill({required this.lang, required this.locProvider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: Colors.white, size: 15.sp),
            SizedBox(width: 5.w),
            Text(
              lang.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final loc = locProvider.loc;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.selectLanguage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ...AppLanguage.values.map(
                (l) => ListTile(
                  leading: Text(l.flag, style: TextStyle(fontSize: 22.sp)),
                  title: Text(
                    l.label,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                  trailing: lang == l
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20.sp,
                        )
                      : null,
                  onTap: () {
                    locProvider.setLanguage(l);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reusable Button ──────────────────────────────────────────────────────────

class _OnboardingButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OnboardingButton({required this.label, required this.onTap});

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
