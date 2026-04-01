// Path: lib/presentation/screens/auth/login_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/common/custom_button.dart';
import '../../../shared/widgets/common/custom_text_field.dart';
import '../../providers/auth_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kGold = Color(0xFFD4A843);
const _kGoldLight = Color(0xFFF0CC6E);
const _kNavy = Color(0xFF0B1120);
const _kNavyMid = Color(0xFF111D35);
const _kCream = Color(0xFFF5EDD8);

// Light mode colours
const _kLightBg = Color(0xFFF8F4ED);
const _kLightCard = Color(0xFFFFFFFF);
const _kLightText = Color(0xFF1A1A2E);
const _kLightSubtext = Color(0xFF6B7280);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  // Animations
  late final AnimationController _patternCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _patternRotate;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _fieldsFade;
  late final Animation<double> _btnFade;
  late final Animation<double> _shakeAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Pattern slowly rotates
    _patternRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _patternCtrl, curve: Curves.linear),
    );

    // Header (logo + title)
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));

    // Card
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.25, 0.65, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic)));

    // Fields
    _fieldsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );

    // Button
    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    // Shake on error
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );

    // Gold pulse
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _patternCtrl.dispose();
    _entryCtrl.dispose();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } else {
      _shakeCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isAuthenticated) context.go('/dashboard');
      if (next.errorMessage != null && !next.isLoading) {
        _shakeCtrl
          ..reset()
          ..forward();
      }
    });

    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? _kNavy : _kLightBg;
    final cardColor = isDark ? _kNavyMid : _kLightCard;
    final titleColor = isDark ? _kCream : _kLightText;
    final subtextColor =
        isDark ? _kCream.withValues(alpha: 0.55) : _kLightSubtext;
    final borderColor = isDark
        ? _kGold.withValues(alpha: 0.25)
        : _kGold.withValues(alpha: 0.35);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────
          Positioned.fill(child: _BackgroundLayer(isDark: isDark)),

          // ── Rotating geometry ─────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _patternRotate,
              builder: (_, __) => CustomPaint(
                painter: _GeometryPainter(
                  rotation: _patternRotate.value,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── Header ──────────────────────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _Header(
                        isDark: isDark,
                        titleColor: titleColor,
                        subtextColor: subtextColor,
                        pulseAnim: _pulseAnim,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Login card ──────────────────────────────────
                  FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, child) {
                          final dx = math.sin(_shakeCtrl.value * math.pi * 8) *
                              8 *
                              (1 - _shakeCtrl.value);
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? _kGold.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Card title row
                                FadeTransition(
                                  opacity: _fieldsFade,
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _kGold.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.login_rounded,
                                          color: _kGold,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: titleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 6),

                                FadeTransition(
                                  opacity: _fieldsFade,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 48),
                                    child: Text(
                                      'أدخل بياناتك للوصول إلى لوحة التحكم',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtextColor,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                _GoldDivider(),
                                const SizedBox(height: 24),

                                // ── Email field ─────────────────
                                FadeTransition(
                                  opacity: _fieldsFade,
                                  child: _StyledField(
                                    controller: _emailCtrl,
                                    label: 'البريد الإلكتروني',
                                    hint: 'example@email.com',
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                    textInputAction: TextInputAction.next,
                                    isDark: isDark,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ── Password field ──────────────
                                FadeTransition(
                                  opacity: _fieldsFade,
                                  child: _StyledField(
                                    controller: _passwordCtrl,
                                    label: 'كلمة المرور',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    isDark: isDark,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: _kGold.withValues(alpha: 0.7),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    onFieldSubmitted: (_) => _handleLogin(),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // ── Login button ────────────────
                                FadeTransition(
                                  opacity: _btnFade,
                                  child: authState.isLoading
                                      ? _LoadingButton(isDark: isDark)
                                      : _LoginButton(onTap: _handleLogin),
                                ),

                                // ── Error message ───────────────
                                if (authState.errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  FadeTransition(
                                    opacity: _btnFade,
                                    child: _ErrorBanner(
                                      message: authState.errorMessage!,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ──────────────────────────────────────
                  FadeTransition(
                    opacity: _btnFade,
                    child: _Footer(subtextColor: subtextColor),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — logo + bismillah + title
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  final Color titleColor;
  final Color subtextColor;
  final Animation<double> pulseAnim;

  const _Header({
    required this.isDark,
    required this.titleColor,
    required this.subtextColor,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bismillah
        Text(
          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          style: TextStyle(
            fontSize: 14,
            color: _kGold.withValues(alpha: isDark ? 0.9 : 0.8),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          textDirection: TextDirection.rtl,
        ),

        const SizedBox(height: 24),

        // Logo with pulsing ring
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Transform.scale(
                scale: pulseAnim.value * 1.15,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kGold.withValues(alpha: isDark ? 0.12 : 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kGold.withValues(alpha: isDark ? 0.3 : 0.4),
                    width: 1.5,
                  ),
                ),
              ),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? _kNavyMid : Colors.white,
                  border: Border.all(color: _kGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withValues(alpha: isDark ? 0.25 : 0.2),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      AssetConstants.LOGO,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.menu_book_rounded,
                        size: 36,
                        color: _kGold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'تطبيق الشيوخ',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: titleColor,
            letterSpacing: 0.5,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 6),
        Text(
          'منصة إدارة حلقات القرآن الكريم',
          style: TextStyle(
            fontSize: 13,
            color: subtextColor,
            letterSpacing: 0.3,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled text field wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor =
        isDark ? _kNavy.withValues(alpha: 0.6) : const Color(0xFFF9F5EE);
    final borderColor =
        isDark ? _kGold.withValues(alpha: 0.2) : _kGold.withValues(alpha: 0.3);
    final focusBorderColor = _kGold;
    final labelColor =
        isDark ? _kCream.withValues(alpha: 0.6) : const Color(0xFF6B7280);
    final textColor = isDark ? _kCream : _kLightText;
    final iconColor = _kGold.withValues(alpha: 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: labelColor.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: iconColor, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: focusBorderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFE53935),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login button
// ─────────────────────────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LoginButton({required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGold, Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kGold.withValues(alpha: _pressed ? 0.2 : 0.4),
                blurRadius: _pressed ? 8 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'دخول',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading button state
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingButton extends StatelessWidget {
  final bool isDark;
  const _LoadingButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kGold.withValues(alpha: 0.6),
            const Color(0xFFB8860B).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorBanner({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE53935), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontSize: 13,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final Color subtextColor;
  const _Footer({required this.subtextColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 30, height: 1, color: _kGold.withValues(alpha: 0.3)),
            const SizedBox(width: 10),
            Icon(Icons.star_rounded,
                color: _kGold.withValues(alpha: 0.5), size: 12),
            const SizedBox(width: 10),
            Container(
                width: 30, height: 1, color: _kGold.withValues(alpha: 0.3)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'للتسجيل يُرجى التواصل مع المسؤول',
          style: TextStyle(fontSize: 12, color: subtextColor),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 4),
        Text(
          '© ${DateTime.now().year} تطبيق الشيوخ',
          style: TextStyle(
            fontSize: 11,
            color: subtextColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold ornamental divider
// ─────────────────────────────────────────────────────────────────────────────
class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
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
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration:
              const BoxDecoration(color: _kGold, shape: BoxShape.circle),
        ),
        const Icon(Icons.star_rounded, color: _kGold, size: 10),
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration:
              const BoxDecoration(color: _kGold, shape: BoxShape.circle),
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
// Background layer
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundLayer extends StatelessWidget {
  final bool isDark;
  const _BackgroundLayer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BgPainter(isDark: isDark),
    );
  }
}

class _BgPainter extends CustomPainter {
  final bool isDark;
  _BgPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Top arc glow
    final topGrad = RadialGradient(
      center: const Alignment(0, -1.3),
      radius: 0.9,
      colors: [
        isDark
            ? const Color(0xFF1A3A5C).withValues(alpha: 0.55)
            : _kGold.withValues(alpha: 0.08),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            topGrad.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Bottom gold glow
    final bottomGrad = RadialGradient(
      center: const Alignment(0, 1.5),
      radius: 0.7,
      colors: [
        _kGold.withValues(alpha: isDark ? 0.06 : 0.05),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = bottomGrad
            .createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic geometric pattern painter
// ─────────────────────────────────────────────────────────────────────────────
class _GeometryPainter extends CustomPainter {
  final double rotation;
  final bool isDark;

  _GeometryPainter({required this.rotation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isDark ? 0.04 : 0.06;
    final paint = Paint()
      ..color = _kGold.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Corner stars
    final corners = [
      const Offset(0.0, 0.0),
      Offset(size.width, 0.0),
      Offset(0.0, size.height),
      Offset(size.width, size.height),
    ];
    for (final c in corners) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rotation * 0.05);
      _drawStar(canvas, paint, size.width * 0.16, 8);
      canvas.restore();
    }

    // Center large star
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.72);
    canvas.rotate(-rotation * 0.04);
    _drawStar(canvas, paint, size.width * 0.22, 8);
    canvas.restore();

    // Top centre smaller
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.1);
    canvas.rotate(rotation * 0.06);
    _drawStar(canvas, paint, size.width * 0.1, 6);
    canvas.restore();
  }

  void _drawStar(Canvas canvas, Paint paint, double r, int pts) {
    final inner = r * 0.42;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi) / pts - math.pi / 2;
      final rad = i.isEven ? r : inner;
      final x = rad * math.cos(angle);
      final y = rad * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset.zero, r * 1.18,
        paint..color = paint.color.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(_GeometryPainter old) =>
      old.rotation != rotation || old.isDark != isDark;
}
