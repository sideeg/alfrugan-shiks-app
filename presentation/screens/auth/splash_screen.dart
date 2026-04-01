// Path: lib/presentation/screens/auth/splash_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/auth_provider.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
const _kNavy = Color(0xFF0B1120);
const _kNavyMid = Color(0xFF111D35);
const _kGold = Color(0xFFD4A843);
const _kGoldLight = Color(0xFFF0CC6E);
const _kCream = Color(0xFFF5EDD8);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _patternCtrl; // rotating geometry
  late final AnimationController _contentCtrl; // main content reveal
  late final AnimationController _pulseCtrl; // gold ring pulse
  late final AnimationController _shimmerCtrl; // shimmer on divider

  // Animations
  late final Animation<double> _patternRotate;
  late final Animation<double> _patternFade;

  late final Animation<double> _bismillahFade;
  late final Animation<Offset> _bismillahSlide;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleFade;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _loadingFade;

  late final Animation<double> _pulseAnim;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // ── Pattern ───────────────────────────────────────────────
    _patternRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _patternCtrl, curve: Curves.linear),
    );
    _patternFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // ── Bismillah ─────────────────────────────────────────────
    _bismillahFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
      ),
    );
    _bismillahSlide = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOutCubic),
    ));

    // ── Logo ──────────────────────────────────────────────────
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.25, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    // ── Title ─────────────────────────────────────────────────
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.5, 0.78, curve: Curves.easeOutCubic),
    ));

    // ── Subtitle + divider + loading ──────────────────────────
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );
    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Pulse + shimmer ───────────────────────────────────────
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // Start content animation after a brief pause
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    context.go(
      isAuthenticated ? RouteConstants.DASHBOARD : RouteConstants.LOGIN,
    );
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    _contentCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // ── 1. Radial background glow ──────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),

          // ── 2. Rotating Islamic geometric pattern ──────────────
          Positioned.fill(
            child: FadeTransition(
              opacity: _patternFade,
              child: AnimatedBuilder(
                animation: _patternRotate,
                builder: (_, __) => CustomPaint(
                  painter: _GeometricPatternPainter(_patternRotate.value),
                ),
              ),
            ),
          ),

          // ── 3. Top decorative arch ─────────────────────────────
          Positioned(
            top: -size.height * 0.08,
            left: -size.width * 0.15,
            right: -size.width * 0.15,
            child: FadeTransition(
              opacity: _patternFade,
              child: CustomPaint(
                size: Size(size.width * 1.3, size.height * 0.45),
                painter: _ArchPainter(),
              ),
            ),
          ),

          // ── 4. Main content ────────────────────────────────────
          Positioned.fill(
              child: SafeArea(
            child: Column(
              children: [
                // Bismillah at the top
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: FadeTransition(
                    opacity: _bismillahFade,
                    child: SlideTransition(
                      position: _bismillahSlide,
                      child: const Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        style: TextStyle(
                          fontSize: 15,
                          color: _kGold,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // ── Logo with pulse ring ───────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          Transform.scale(
                            scale: _pulseAnim.value * 1.25,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _kGold.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          // Mid ring
                          Transform.scale(
                            scale: _pulseAnim.value * 1.1,
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _kGold.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Logo container
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_kNavyMid, _kNavy],
                              ),
                              border: Border.all(
                                color: _kGold,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kGold.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Image.asset(
                                  'assets/icons/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.menu_book_rounded,
                                    size: 44,
                                    color: _kGold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── App name ───────────────────────────────────
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        const Text(
                          'تطبيق الشيوخ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _kCream,
                            letterSpacing: 1.0,
                            height: 1.2,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 6),
                        // Gold shimmer divider
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: AnimatedBuilder(
                            animation: _dividerWidth,
                            builder: (_, __) => SizedBox(
                              width: 180 * _dividerWidth.value,
                              child: const _GoldDivider(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: Text(
                            'منصة إدارة حلقات القرآن الكريم',
                            style: TextStyle(
                              fontSize: 14,
                              color: _kCream.withValues(alpha: 0.65),
                              letterSpacing: 0.5,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ── Bottom loading section ─────────────────────
                FadeTransition(
                  opacity: _loadingFade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: Column(
                      children: [
                        // Dot loader
                        const _GoldDotLoader(),
                        const SizedBox(height: 18),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kGold.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )), // ← closes SafeArea + Positioned.fill
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold ornamental divider
// ─────────────────────────────────────────────────────────────────────────────
class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _kGold],
              ),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            color: _kGold,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: _kGoldLight,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            color: _kGold,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kGold, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated gold dot loader
// ─────────────────────────────────────────────────────────────────────────────
class _GoldDotLoader extends StatefulWidget {
  const _GoldDotLoader();

  @override
  State<_GoldDotLoader> createState() => _GoldDotLoaderState();
}

class _GoldDotLoaderState extends State<_GoldDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final scale = math.sin(t * math.pi).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withValues(
                  alpha: 0.3 + scale * 0.7,
                ),
              ),
              transform: Matrix4.identity()..translate(0.0, -scale * 5),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background radial glow painter
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Center gold glow
    final centerGlow = RadialGradient(
      center: Alignment.center,
      radius: 0.7,
      colors: [
        _kGold.withValues(alpha: 0.06),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = centerGlow.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    // Top blue-teal accent
    final topGlow = RadialGradient(
      center: const Alignment(0, -1.4),
      radius: 0.8,
      colors: [
        const Color(0xFF1A3A5C).withValues(alpha: 0.6),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = topGlow.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Arch painter — decorative top arch
// ─────────────────────────────────────────────────────────────────────────────
class _ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kGold.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final scale = 0.65 + i * 0.12;
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.1),
        width: size.width * scale,
        height: size.height * scale * 0.9,
      );
      canvas.drawArc(rect, math.pi, math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic 8-point star geometric pattern (slowly rotating, subtle)
// ─────────────────────────────────────────────────────────────────────────────
class _GeometricPatternPainter extends CustomPainter {
  final double rotation;
  _GeometricPatternPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kGold.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw tiled 8-point stars
    final tileSize = size.width * 0.38;
    final offsets = [
      Offset(cx, cy),
      Offset(cx - tileSize, cy - tileSize),
      Offset(cx + tileSize, cy - tileSize),
      Offset(cx - tileSize, cy + tileSize),
      Offset(cx + tileSize, cy + tileSize),
      Offset(cx, cy - tileSize * 1.6),
      Offset(cx, cy + tileSize * 1.6),
    ];

    for (final o in offsets) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(rotation * 0.08); // very slow drift
      _drawStar(canvas, paint, tileSize * 0.45, 8);
      canvas.rotate(math.pi / 8);
      _drawStar(canvas, paint, tileSize * 0.3, 8);
      canvas.restore();
    }

    // Corner ornaments
    final cornerPaint = Paint()
      ..color = _kGold.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final corners = [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final c in corners) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      _drawStar(canvas, cornerPaint, size.width * 0.14, 8);
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double radius, int points) {
    final path = Path();
    final innerRadius = radius * 0.42;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Outer decorative circle
    canvas.drawCircle(Offset.zero, radius * 1.15,
        paint..color = paint.color.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_GeometricPatternPainter old) => old.rotation != rotation;
}
