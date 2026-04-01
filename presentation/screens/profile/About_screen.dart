// Path: lib/presentation/screens/about/about_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  static const String _companyWebsite = 'https://sideeg.com';
  static const String _email = 'info@sideeg.com';

  // Loaded at runtime from pubspec.yaml via package_info_plus
  String _appVersion = '';
  String _appBuild = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadVersion(); // reads version + buildNumber from pubspec.yaml
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  /// Reads version & build number from pubspec.yaml at runtime.
  /// Requires: package_info_plus in pubspec.yaml dependencies.
  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version; // e.g. '1.0.0'
        _appBuild = info.buildNumber; // e.g. '100'
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _navy : _lightBg,
        body: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              _TopBar(isDark: isDark, version: _appVersion),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Brand hero ─────────────────────────────
                      _BrandHero(
                          version: _appVersion,
                          buildNumber: _appBuild,
                          isDark: isDark),
                      const SizedBox(height: 24),

                      // ── Stats ───────────────────────────────────
                      _StatsRow(isDark: isDark),
                      const SizedBox(height: 24),

                      // ── About text ──────────────────────────────
                      _CardSection(
                        isDark: isDark,
                        icon: Icons.info_rounded,
                        iconColor: _gold,
                        title: 'عن التطبيق',
                        child: _AboutText(isDark: isDark),
                      ),
                      const SizedBox(height: 14),

                      // ── Features ────────────────────────────────
                      _CardSection(
                        isDark: isDark,
                        icon: Icons.stars_rounded,
                        iconColor: _gold,
                        title: 'المميزات',
                        child: _FeaturesList(isDark: isDark),
                      ),
                      const SizedBox(height: 14),

                      // ── Developer ───────────────────────────────
                      _CardSection(
                        isDark: isDark,
                        icon: Icons.business_rounded,
                        iconColor: _gold,
                        title: 'المطوّر',
                        child: _DeveloperSection(
                            isDark: isDark,
                            onWebsite: () => _launchUrl(_companyWebsite),
                            onEmail: () => _launchUrl('mailto:$_email')),
                      ),
                      const SizedBox(height: 14),

                      // ── Legal ────────────────────────────────────
                      _CardSection(
                        isDark: isDark,
                        icon: Icons.gavel_rounded,
                        iconColor: _gold,
                        title: 'قانوني',
                        child: _LegalSection(
                          isDark: isDark,
                          onPrivacy: () =>
                              _launchUrl('$_companyWebsite/privacy'),
                          onTerms: () => _launchUrl('$_companyWebsite/terms'),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Footer ───────────────────────────────────
                      _Footer(version: _appVersion, isDark: isDark),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final String version;
  const _TopBar({required this.isDark, required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              right: -28,
              top: -28,
              child: CustomPaint(
                  size: const Size(130, 130),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.05)))),
          Positioned(
              left: -12,
              bottom: -8,
              child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.04)))),
          // Gold accent line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    _gold.withValues(alpha: 0.0),
                    _gold.withValues(alpha: 0.5),
                    _gold.withValues(alpha: 0.0)
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2))),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 14, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('حول التطبيق',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(version.isEmpty ? '' : 'الإصدار $version',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _gold.withValues(alpha: 0.3))),
                      child: const Icon(Icons.info_outline_rounded,
                          color: _gold, size: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand hero ───────────────────────────────────────────────────────────────
class _BrandHero extends StatelessWidget {
  final String version, buildNumber;
  final bool isDark;
  const _BrandHero(
      {required this.version, required this.buildNumber, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
              color: _navy.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Stack(
        children: [
          Positioned(
              right: -20,
              top: -20,
              child: CustomPaint(
                  size: const Size(110, 110),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.07)))),
          Positioned(
              left: -14,
              bottom: -14,
              child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.04)))),
          Column(
            children: [
              // Logo container with double gold ring
              Stack(alignment: Alignment.center, children: [
                Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.25), width: 1))),
                Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.4), width: 1.5))),
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.12),
                    border: Border.all(color: _gold.withValues(alpha: 0.25)),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/icons/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book_rounded,
                            size: 36,
                            color: _gold)),
                  ),
                ),
              ]),

              const SizedBox(height: 18),

              const Text('تطبيق الشيوخ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text('منصة إدارة حلقات القرآن الكريم',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55))),

              const SizedBox(height: 18),

              // Gold ornamental divider
              Row(children: [
                Expanded(
                    child: Container(
                        height: 1, color: _gold.withValues(alpha: 0.2))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withValues(alpha: 0.6)))),
                Expanded(
                    child: Container(
                        height: 1, color: _gold.withValues(alpha: 0.2))),
              ]),

              const SizedBox(height: 16),

              // Version badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.35)),
                ),
                child: Text('الإصدار $version  •  بناء $buildNumber',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _gold,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            isDark: isDark,
            value: '٥٠٠+',
            label: 'شيخ',
            icon: Icons.person_rounded,
            color: const Color(0xFF2E7D32),
            index: 0),
        const SizedBox(width: 10),
        _StatCard(
            isDark: isDark,
            value: '٢٠٠٠+',
            label: 'طالب',
            icon: Icons.school_rounded,
            color: const Color(0xFF1565C0),
            index: 1),
        const SizedBox(width: 10),
        _StatCard(
            isDark: isDark,
            value: '١٠٠+',
            label: 'حلقة',
            icon: Icons.groups_rounded,
            color: const Color(0xFF6A1B9A),
            index: 2),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final bool isDark;
  final String value, label;
  final IconData icon;
  final Color color;
  final int index;
  const _StatCard(
      {required this.isDark,
      required this.value,
      required this.label,
      required this.icon,
      required this.color,
      required this.index});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 120 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? _navyMid : _lightCard;
    return Expanded(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : widget.color.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: Icon(widget.icon, color: widget.color, size: 18)),
                const SizedBox(height: 8),
                Text(widget.value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.color)),
                const SizedBox(height: 2),
                Text(widget.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark
                            ? Colors.grey[500]
                            : Colors.grey[500])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generic card section ─────────────────────────────────────────────────────
class _CardSection extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _CardSection(
      {required this.isDark,
      required this.icon,
      required this.iconColor,
      required this.title,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: isDark
                    ? _navyLight.withValues(alpha: 0.5)
                    : _gold.withValues(alpha: 0.04),
                border: Border(
                    bottom: BorderSide(color: _gold.withValues(alpha: 0.12))),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              color: iconColor.withValues(alpha: 0.25))),
                      child: Icon(icon, size: 15, color: iconColor)),
                  const SizedBox(width: 10),
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textClr)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── About text ───────────────────────────────────────────────────────────────
class _AboutText extends StatelessWidget {
  final bool isDark;
  const _AboutText({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    return Text(
      'تطبيق الشيوخ هو منصة متكاملة لإدارة حلقات تحفيظ القرآن الكريم، '
      'يُمكّن الشيوخ والمعلمين من متابعة تقدم طلابهم وتسجيل سجلات '
      'الحفظ والمراجعة بكل سهولة ويسر.',
      style: TextStyle(fontSize: 13, color: subClr, height: 1.8),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }
}

// ─── Features list ────────────────────────────────────────────────────────────
class _FeaturesList extends StatelessWidget {
  final bool isDark;
  const _FeaturesList({required this.isDark});

  static const _features = [
    (
      Icons.menu_book_rounded,
      Color(0xFF2E7D32),
      'إدارة الدورات',
      'تنظيم دوراتك وحلقاتك في مكان واحد'
    ),
    (
      Icons.people_alt_rounded,
      Color(0xFF1565C0),
      'متابعة الطلاب',
      'تتبع تقدم كل طالب بدقة وسهولة'
    ),
    (
      Icons.assignment_rounded,
      Color(0xFF6A1B9A),
      'سجلات الحفظ',
      'تسجيل وأرشفة جلسات الحفظ والمراجعة'
    ),
    (
      Icons.notifications_active_rounded,
      Color(0xFFE65100),
      'الإشعارات',
      'تنبيهات فورية لأهم الأحداث والتحديثات'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _features.length; i++) ...[
          _FeatureRow(
            isDark: isDark,
            icon: _features[i].$1,
            color: _features[i].$2,
            title: _features[i].$3,
            subtitle: _features[i].$4,
          ),
          if (i < _features.length - 1)
            Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04)),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _FeatureRow(
      {required this.isDark,
      required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2))),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textClr),
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 11, color: subClr),
                  textDirection: TextDirection.rtl),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
            child: Icon(Icons.check_rounded,
                size: 13, color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}

// ─── Developer section ────────────────────────────────────────────────────────
class _DeveloperSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onWebsite, onEmail;
  const _DeveloperSection(
      {required this.isDark, required this.onWebsite, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            // Dev avatar
            Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF1A3A6C), _navy]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.code_rounded, color: _gold, size: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('صديق محمد ميرغني',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textClr),
                      textDirection: TextDirection.rtl),
                  const SizedBox(height: 4),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _whatsAppGreen)),
                      const SizedBox(width: 5),
                      Text('حلول تقنية متكاملة',
                          style: TextStyle(fontSize: 12, color: subClr),
                          textDirection: TextDirection.rtl),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _DevBtn(
                    icon: Icons.language_rounded,
                    label: 'الموقع',
                    color: _gold,
                    onTap: onWebsite)),
            const SizedBox(width: 10),
            Expanded(
                child: _DevBtn(
                    icon: Icons.email_rounded,
                    label: 'راسلنا',
                    color: const Color(0xFF1565C0),
                    onTap: onEmail)),
          ],
        ),
      ],
    );
  }
}

const _whatsAppGreen = Color(0xFF25D366);

class _DevBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DevBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  State<_DevBtn> createState() => _DevBtnState();
}

class _DevBtnState extends State<_DevBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          widget.onTap();
        },
        onTapCancel: () => _press.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: widget.color.withValues(alpha: 0.25))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(widget.icon, color: widget.color, size: 16),
              const SizedBox(width: 7),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.color)),
            ]),
          ),
        ),
      );
}

// ─── Legal section ────────────────────────────────────────────────────────────
class _LegalSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPrivacy, onTerms;
  const _LegalSection(
      {required this.isDark, required this.onPrivacy, required this.onTerms});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LegalRow(isDark: isDark, label: 'سياسة الخصوصية', onTap: onPrivacy),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04)),
        _LegalRow(isDark: isDark, label: 'شروط الاستخدام', onTap: onTerms),
      ],
    );
  }
}

class _LegalRow extends StatefulWidget {
  final bool isDark;
  final String label;
  final VoidCallback onTap;
  const _LegalRow(
      {required this.isDark, required this.label, required this.onTap});

  @override
  State<_LegalRow> createState() => _LegalRowState();
}

class _LegalRowState extends State<_LegalRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textClr = widget.isDark ? _cream : _navy;
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7)),
                  child: const Icon(Icons.shield_outlined,
                      size: 14, color: _gold)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(widget.label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textClr),
                      textDirection: TextDirection.rtl)),
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 12,
                  color: widget.isDark ? Colors.grey[600] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final String version;
  final bool isDark;
  const _Footer({required this.version, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subClr = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    return Column(
      children: [
        // Quran verse card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [_navyMid, _navyMid]
                  : [
                      _gold.withValues(alpha: 0.05),
                      _gold.withValues(alpha: 0.02)
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _gold.withValues(alpha: 0.2)),
          ),
          child: Stack(
            children: [
              Positioned(
                  right: -10,
                  top: -10,
                  child: CustomPaint(
                      size: const Size(70, 70),
                      painter: _StarBg(color: _gold.withValues(alpha: 0.06)))),
              Column(
                children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: _gold.withValues(alpha: 0.25))),
                      child: const Icon(Icons.format_quote_rounded,
                          color: _gold, size: 20)),
                  const SizedBox(height: 12),
                  const Text('﴿ وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا ﴾',
                      style: TextStyle(
                          fontSize: 18,
                          color: _gold,
                          fontWeight: FontWeight.w600,
                          height: 1.6),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl),
                  const SizedBox(height: 6),
                  Text('سورة المزمل – آية ٤',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[500]),
                      textDirection: TextDirection.rtl),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Gold ornamental line
        Row(children: [
          Expanded(
              child:
                  Container(height: 1, color: _gold.withValues(alpha: 0.15))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.4)))),
          Expanded(
              child:
                  Container(height: 1, color: _gold.withValues(alpha: 0.15))),
        ]),

        const SizedBox(height: 16),

        Text('© ${DateTime.now().year} صديق محمد ميرغني',
            style: TextStyle(fontSize: 12, color: subClr),
            textDirection: TextDirection.rtl),
        const SizedBox(height: 4),
        Text('جميع الحقوق محفوظة  •  الإصدار $version',
            style: TextStyle(fontSize: 11, color: subClr),
            textDirection: TextDirection.rtl),
      ],
    );
  }
}

// ─── Star background painter ──────────────────────────────────────────────────
class _StarBg extends CustomPainter {
  final Color color;
  const _StarBg({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + r * 0.42 * math.cos(angle - 0.22),
            cy + r * 0.42 * math.sin(angle - 0.22))
        ..lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle))
        ..lineTo(cx + r * 0.42 * math.cos(angle + 0.22),
            cy + r * 0.42 * math.sin(angle + 0.22))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarBg old) => old.color != color;
}
