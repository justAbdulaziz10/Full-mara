import 'package:flutter/material.dart';

/// Splash screen خفيفة مع فِيد-إن + دعم لايت/دارك + انتقال تلقائي.
/// غيّر [nextRoute] لو تبغى يروح للأونبوردنق مثلاً.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.nextRoute = '/home'});

  /// المسار التالي بعد انتهاء السبلّاش
  final String nextRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // أنيميشن فِيد-إن
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // انتظر 2.5 ثانية ثم انتقل
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      // مثال لو بتقرر الوجهة حسب تسجيل الدخول:
      // final bool isLoggedIn = context.read<AuthCubit>().state is Authenticated;
      // final String route = isLoggedIn ? '/home' : '/auth';
      // Navigator.pushReplacementNamed(context, route);

      Navigator.pushReplacementNamed(context, widget.nextRoute);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    // تأكد إنك ضايف هذي الأصول في pubspec.yaml تحت flutter/assets
    // assets/logo_light.png و assets/logo_dark.png
    final String logoPath = isDark
        ? 'assets/logo_dark.png'
        : 'assets/logo_light.png';

    // نخلي الخلفية متوافقة مع ثيم التطبيق
    final Color bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Image.asset(
              logoPath,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              // مفيدة للقارئات
              semanticLabel: 'Mara logo',
            ),
          ),
        ),
      ),
    );
  }
}
