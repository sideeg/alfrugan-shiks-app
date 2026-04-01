// Path: lib/presentation/screens/profile/change_password_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/presentation/providers/profile_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  // Live password strength
  double _strength = 0;
  String _strengthLbl = '';
  Color _strengthClr = Colors.transparent;

  // Per-requirement live checks
  bool _has8 = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasDigit = false;
  bool _hasSymbol = false;

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
    _newCtrl.addListener(_checkStrength);
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _checkStrength() {
    final v = _newCtrl.text;
    setState(() {
      _has8 = v.length >= 8;
      _hasUpper = v.contains(RegExp(r'[A-Z]'));
      _hasLower = v.contains(RegExp(r'[a-z]'));
      _hasDigit = v.contains(RegExp(r'[0-9]'));
      _hasSymbol = v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

      final score = [_has8, _hasUpper, _hasLower, _hasDigit, _hasSymbol]
          .where((b) => b)
          .length;

      _strength = score / 5;
      if (score <= 1) {
        _strengthLbl = 'ضعيفة جداً';
        _strengthClr = const Color(0xFFE53935);
      } else if (score == 2) {
        _strengthLbl = 'ضعيفة';
        _strengthClr = const Color(0xFFFF7043);
      } else if (score == 3) {
        _strengthLbl = 'متوسطة';
        _strengthClr = const Color(0xFFFFA726);
      } else if (score == 4) {
        _strengthLbl = 'جيدة';
        _strengthClr = _gold;
      } else {
        _strengthLbl = 'قوية جداً';
        _strengthClr = const Color(0xFF2E7D32);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(profileProvider.notifier).updatePassword(
            currentPassword: _currentCtrl.text.trim(),
            newPassword: _newCtrl.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<ProfileState>(profileProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      } else if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.pop();
        });
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _navy : _lightBg,
        body: Stack(
          children: [
            Column(
              children: [
                // ── Navy gradient top bar ──────────────────────
                _TopBar(isDark: isDark),
                // ── Scrollable content ─────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Security tip banner
                            _TipBanner(isDark: isDark),
                            const SizedBox(height: 24),

                            // Fields card
                            _SectionLabel(
                                label: 'إدخال كلمات المرور', isDark: isDark),
                            const SizedBox(height: 12),
                            _FieldsCard(
                              isDark: isDark,
                              currentCtrl: _currentCtrl,
                              newCtrl: _newCtrl,
                              confirmCtrl: _confirmCtrl,
                              showCurrent: _showCurrent,
                              showNew: _showNew,
                              showConfirm: _showConfirm,
                              onToggleCurrent: () =>
                                  setState(() => _showCurrent = !_showCurrent),
                              onToggleNew: () =>
                                  setState(() => _showNew = !_showNew),
                              onToggleConfirm: () =>
                                  setState(() => _showConfirm = !_showConfirm),
                            ),

                            // Strength bar (visible when typing)
                            if (_newCtrl.text.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _StrengthBar(
                                strength: _strength,
                                label: _strengthLbl,
                                color: _strengthClr,
                                isDark: isDark,
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Requirements card
                            _SectionLabel(
                                label: 'متطلبات كلمة المرور', isDark: isDark),
                            const SizedBox(height: 12),
                            _RequirementsCard(
                              isDark: isDark,
                              has8: _has8,
                              hasUpper: _hasUpper,
                              hasLower: _hasLower,
                              hasDigit: _hasDigit,
                              hasSymbol: _hasSymbol,
                            ),

                            const SizedBox(height: 32),

                            // Submit button
                            _SubmitButton(
                              isDark: isDark,
                              loading: profileState.isLoading,
                              onTap: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (profileState.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                    child: CircularProgressIndicator(color: _gold)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar (matches profile/edit nav bar) ───────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // Subtle star watermark in top-right
          Positioned(
            right: -24,
            top: -24,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _StarBg(color: _gold.withValues(alpha: 0.05)),
            ),
          ),
          // Gold accent bottom line
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
                    _gold.withValues(alpha: 0.0),
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
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('تغيير كلمة المرور',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('حافظ على أمان حسابك',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  // Lock icon badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withValues(alpha: 0.3)),
                    ),
                    child:
                        const Icon(Icons.lock_rounded, color: _gold, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Security tip banner ──────────────────────────────────────────────────────
class _TipBanner extends StatelessWidget {
  final bool isDark;
  const _TipBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.shield_rounded, size: 17, color: _gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تأكد من أن كلمة المرور الجديدة قوية وآمنة ولم تستخدمها من قبل',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? _gold.withValues(alpha: 0.85) : _goldDeep,
                  height: 1.5),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
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
              height: 14,
              decoration: BoxDecoration(
                  color: _gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? _cream.withValues(alpha: 0.8)
                      : _navy.withValues(alpha: 0.7))),
        ],
      );
}

// ─── Fields card ──────────────────────────────────────────────────────────────
class _FieldsCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController currentCtrl, newCtrl, confirmCtrl;
  final bool showCurrent, showNew, showConfirm;
  final VoidCallback onToggleCurrent, onToggleNew, onToggleConfirm;

  const _FieldsCard({
    required this.isDark,
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.showCurrent,
    required this.showNew,
    required this.showConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _navyMid : _lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _PasswordField(
            controller: currentCtrl,
            label: 'كلمة المرور الحالية',
            iconColor: const Color(0xFF6A1B9A),
            isDark: isDark,
            isVisible: showCurrent,
            onToggle: onToggleCurrent,
            inputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
              return null;
            },
          ),
          _Divider(isDark: isDark),
          _PasswordField(
            controller: newCtrl,
            label: 'كلمة المرور الجديدة',
            iconColor: const Color(0xFF1565C0),
            isDark: isDark,
            isVisible: showNew,
            onToggle: onToggleNew,
            inputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
              if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
              return null;
            },
          ),
          _Divider(isDark: isDark),
          _PasswordField(
            controller: confirmCtrl,
            label: 'تأكيد كلمة المرور الجديدة',
            iconColor: const Color(0xFF2E7D32),
            isDark: isDark,
            isVisible: showConfirm,
            onToggle: onToggleConfirm,
            inputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
              if (v != newCtrl.text) return 'كلمة المرور غير متطابقة';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// ─── Single password field ────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color iconColor;
  final bool isDark, isVisible;
  final VoidCallback onToggle;
  final TextInputAction inputAction;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.iconColor,
    required this.isDark,
    required this.isVisible,
    required this.onToggle,
    required this.inputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      textInputAction: inputAction,
      textDirection: TextDirection.rtl,
      style:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textClr),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: subClr),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_rounded, size: 16, color: iconColor),
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Icon(
              isVisible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
      );
}

// ─── Strength bar ─────────────────────────────────────────────────────────────
class _StrengthBar extends StatelessWidget {
  final double strength;
  final String label;
  final Color color;
  final bool isDark;

  const _StrengthBar({
    required this.strength,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? _navyMid : _lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('قوة كلمة المرور',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(
                  height: 5,
                  width: double.infinity,
                  color: isDark
                      ? _navyLight
                      : Colors.grey.withValues(alpha: 0.12)),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                widthFactor: strength,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [color, color.withValues(alpha: 0.6)],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Requirements card ────────────────────────────────────────────────────────
class _RequirementsCard extends StatelessWidget {
  final bool isDark;
  final bool has8, hasUpper, hasLower, hasDigit, hasSymbol;

  const _RequirementsCard({
    required this.isDark,
    required this.has8,
    required this.hasUpper,
    required this.hasLower,
    required this.hasDigit,
    required this.hasSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? _navyMid : _lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReqRow('8 أحرف على الأقل', has8, isDark),
        ],
      ),
    );
  }

  Widget _buildReqRow(String text, bool met, bool isDark,
      {bool isLast = false}) {
    final metClr = const Color(0xFF2E7D32);
    final unmetClr = isDark ? Colors.grey[500]! : Colors.grey[400]!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      met ? metClr.withValues(alpha: 0.12) : Colors.transparent,
                  border: Border.all(
                      color: met
                          ? metClr.withValues(alpha: 0.4)
                          : unmetClr.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(
                    met
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 13,
                    color: met ? metClr : unmetClr,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 13,
                      color: met
                          ? (isDark ? _cream.withValues(alpha: 0.85) : _navy)
                          : unmetClr,
                      fontWeight: met ? FontWeight.w500 : FontWeight.normal),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.04),
          ),
      ],
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────
class _SubmitButton extends StatefulWidget {
  final bool isDark, loading;
  final VoidCallback onTap;
  const _SubmitButton(
      {required this.isDark, required this.loading, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [_gold, Color(0xFFB8860B)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_reset_rounded,
                          size: 18, color: Colors.white),
                      SizedBox(width: 10),
                      Text('تحديث كلمة المرور',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
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
