// Path: lib/presentation/screens/support/support_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);
const _whatsApp = Color(0xFF25D366);

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  static const String _email = 'info@sideeg.com';
  static const String _whatsapp = '+256766699449';
  static const String _whatsappNumber = '256766699449';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': 'دعم تطبيق الشيوخ',
        'body': 'السلام عليكم،\n\nأحتاج إلى مساعدة بخصوص...',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(const ClipboardData(text: _email));
      if (mounted) _toast('تم نسخ البريد الإلكتروني ✓');
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent('السلام عليكم، أحتاج إلى مساعدة بخصوص تطبيق الشيوخ')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: _whatsapp));
      if (mounted) _toast('تم نسخ رقم الواتساب ✓');
    }
  }

  void _toast(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? _navyMid : _navy,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _gold.withValues(alpha: 0.4))),
      duration: const Duration(seconds: 2),
    ));
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
              _TopBar(isDark: isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(isDark: isDark),
                      const SizedBox(height: 28),
                      _SectionLabel(label: 'تواصل معنا', isDark: isDark),
                      const SizedBox(height: 4),
                      _SectionSub(
                          text: 'نحن هنا لمساعدتك، اختر الطريقة الأنسب لك',
                          isDark: isDark),
                      const SizedBox(height: 14),
                      _ContactCard(
                        isDark: isDark,
                        icon: Icons.chat_rounded,
                        iconColor: _whatsApp,
                        title: 'واتساب',
                        subtitle: 'رد سريع خلال دقائق',
                        value: _whatsapp,
                        badgeLabel: 'الأسرع',
                        badgeColor: _whatsApp,
                        onTap: _launchWhatsApp,
                        onCopy: () async {
                          await Clipboard.setData(
                              const ClipboardData(text: _whatsapp));
                          _toast('تم نسخ رقم الواتساب ✓');
                        },
                      ),
                      const SizedBox(height: 12),
                      _ContactCard(
                        isDark: isDark,
                        icon: Icons.email_rounded,
                        iconColor: _gold,
                        title: 'البريد الإلكتروني',
                        subtitle: 'للاستفسارات التفصيلية',
                        value: _email,
                        onTap: _launchEmail,
                        onCopy: () async {
                          await Clipboard.setData(
                              const ClipboardData(text: _email));
                          _toast('تم نسخ البريد الإلكتروني ✓');
                        },
                      ),
                      const SizedBox(height: 32),
                      _SectionLabel(label: 'أسئلة شائعة', isDark: isDark),
                      const SizedBox(height: 14),
                      _FaqItem(
                        isDark: isDark,
                        index: 0,
                        question: 'كيف أضيف سجل حفظ جديد؟',
                        answer:
                            'من الصفحة الرئيسية، اضغط على زر "إضافة سجل حفظ" ثم اختر الدورة والطالب وأدخل البيانات المطلوبة.',
                      ),
                      const SizedBox(height: 10),
                      _FaqItem(
                        isDark: isDark,
                        index: 1,
                        question: 'كيف أغير كلمة المرور؟',
                        answer:
                            'اذهب إلى الملف الشخصي ← إعدادات الحساب ← تغيير كلمة المرور، ثم أدخل كلمة المرور الحالية والجديدة.',
                      ),
                      const SizedBox(height: 10),
                      _FaqItem(
                        isDark: isDark,
                        index: 2,
                        question: 'ماذا أفعل إذا نسيت كلمة المرور؟',
                        answer:
                            'تواصل معنا عبر واتساب أو البريد الإلكتروني وسنساعدك في استعادة الوصول إلى حسابك.',
                      ),
                      const SizedBox(height: 32),
                      _WorkingHoursCard(isDark: isDark),
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
  const _TopBar({required this.isDark});

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
                  size: const Size(120, 120),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.05)))),
          Positioned(
              left: -16,
              bottom: -10,
              child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.04)))),
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
                        const Text('المساعدة والدعم',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('نحن هنا لمساعدتك',
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
                      child: const Icon(Icons.support_agent_rounded,
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

// ─── Hero card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool isDark;
  const _HeroCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: _navy.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Stack(
        children: [
          Positioned(
              right: -16,
              top: -16,
              child: CustomPaint(
                  size: const Size(100, 100),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.06)))),
          Positioned(
              left: -10,
              bottom: -10,
              child: CustomPaint(
                  size: const Size(70, 70),
                  painter: _StarBg(color: _gold.withValues(alpha: 0.04)))),
          Column(
            children: [
              Stack(alignment: Alignment.center, children: [
                Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.3), width: 1.5))),
                Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withValues(alpha: 0.15)),
                    child: const Icon(Icons.support_agent_rounded,
                        size: 34, color: _gold)),
              ]),
              const SizedBox(height: 16),
              const Text('مرحباً، كيف يمكننا مساعدتك؟',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 8),
              Text('فريق الدعم متاح للإجابة على استفساراتك',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.4),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 18),
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
                            color: _gold.withValues(alpha: 0.5)))),
                Expanded(
                    child: Container(
                        height: 1, color: _gold.withValues(alpha: 0.2))),
              ]),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _whatsApp)),
                  const SizedBox(width: 7),
                  const Text('متاح الآن للمساعدة',
                      style: TextStyle(
                          fontSize: 12,
                          color: _gold,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section labels ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: _gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? _cream : _navy)),
        ],
      );
}

class _SectionSub extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionSub({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 11),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[500]),
            textDirection: TextDirection.rtl),
      );
}

// ─── Contact card ─────────────────────────────────────────────────────────────
class _ContactCard extends StatefulWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title, subtitle, value;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback onTap, onCopy;

  const _ContactCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    this.badgeLabel,
    this.badgeColor,
    required this.onTap,
    required this.onCopy,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
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
    final cardBg = widget.isDark ? _navyMid : _lightCard;
    final textClr = widget.isDark ? _cream : _navy;
    final subClr = widget.isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Left accent bar
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.iconColor,
                          widget.iconColor.withValues(alpha: 0.3)
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: widget.iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color:
                                      widget.iconColor.withValues(alpha: 0.2))),
                          child: Icon(widget.icon,
                              size: 24, color: widget.iconColor)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(textDirection: TextDirection.rtl, children: [
                              Text(widget.title,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textClr)),
                              if (widget.badgeLabel != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: widget.badgeColor!
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: widget.badgeColor!
                                              .withValues(alpha: 0.3))),
                                  child: Text(widget.badgeLabel!,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: widget.badgeColor)),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 3),
                            Text(widget.subtitle,
                                style: TextStyle(fontSize: 11, color: subClr),
                                textDirection: TextDirection.rtl),
                            const SizedBox(height: 4),
                            Text(widget.value,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: widget.iconColor,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onCopy,
                        child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                    color: _gold.withValues(alpha: 0.2))),
                            child: const Icon(Icons.copy_rounded,
                                size: 15, color: _gold)),
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

// ─── FAQ item ─────────────────────────────────────────────────────────────────
class _FaqItem extends StatefulWidget {
  final bool isDark;
  final int index;
  final String question, answer;

  const _FaqItem(
      {required this.isDark,
      required this.index,
      required this.question,
      required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? _navyMid : _lightCard;
    final textClr = widget.isDark ? _cream : _navy;
    final subClr = widget.isDark ? Colors.grey[400]! : Colors.grey[600]!;
    const nums = ['١', '٢', '٣'];
    final num =
        widget.index < nums.length ? nums[widget.index] : '${widget.index + 1}';

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _open
                  ? _gold.withValues(alpha: 0.4)
                  : _gold.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _open ? 12 : 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: _open
                            ? _gold.withValues(alpha: 0.2)
                            : _gold.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _open
                                ? _gold.withValues(alpha: 0.5)
                                : _gold.withValues(alpha: 0.2))),
                    child: Center(
                        child: Text(num,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _open
                                    ? _gold
                                    : _gold.withValues(alpha: 0.5)))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.question,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textClr,
                              height: 1.4),
                          textDirection: TextDirection.rtl)),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                            color: _open
                                ? _gold.withValues(alpha: 0.15)
                                : Colors.transparent,
                            shape: BoxShape.circle),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: _open ? _gold : subClr)),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expand,
              child: Column(children: [
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    color: _gold.withValues(alpha: 0.15)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 52, 14),
                  child: Text(widget.answer,
                      style:
                          TextStyle(fontSize: 13, color: subClr, height: 1.65),
                      textDirection: TextDirection.rtl),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Working hours card ───────────────────────────────────────────────────────
class _WorkingHoursCard extends StatelessWidget {
  final bool isDark;
  const _WorkingHoursCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                          _gold,
                          _gold.withValues(alpha: 0.3),
                          _gold.withValues(alpha: 0.0)
                        ])))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _gold.withValues(alpha: 0.25))),
                      child: const Icon(Icons.access_time_rounded,
                          color: _gold, size: 20)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('أوقات الدعم',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textClr)),
                        const SizedBox(height: 8),
                        _HourRow(
                            isDark: isDark,
                            day: 'السبت – الخميس',
                            time: '٩ صباحاً – ٩ مساءً',
                            subClr: subClr),
                        const SizedBox(height: 5),
                        _HourRow(
                            isDark: isDark,
                            day: 'الجمعة',
                            time: '٢ ظهراً – ٩ مساءً',
                            subClr: subClr),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  final bool isDark;
  final String day, time;
  final Color subClr;
  const _HourRow(
      {required this.isDark,
      required this.day,
      required this.time,
      required this.subClr});

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: _gold.withValues(alpha: 0.5))),
          const SizedBox(width: 8),
          Text('$day: ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? _cream.withValues(alpha: 0.8) : _navy)),
          Text(time, style: TextStyle(fontSize: 12, color: subClr)),
        ],
      );
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
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
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
