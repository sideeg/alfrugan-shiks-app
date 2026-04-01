// Path: lib/presentation/screens/profile/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/core/utils/validators.dart';
import 'package:quran_sheikh_app/domain/entities/profile_update_request.dart';
import 'package:quran_sheikh_app/presentation/providers/profile_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _eGold = Color(0xFFD4A843);
const _eNavy = Color(0xFF0B1120);
const _eNavyMid = Color(0xFF111D35);
const _eCream = Color(0xFFF5EDD8);
const _eLightBg = Color(0xFFF2F4F8);
const _eLightCard = Color(0xFFFFFFFF);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _qiraatCtrl = TextEditingController();

  File? _selectedImage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final p = ref.read(profileProvider).profile;
    if (p != null) {
      _nameCtrl.text = p.name;
      _emailCtrl.text = p.email;
      _phoneCtrl.text = p.phone ?? '';
      _nationalIdCtrl.text = p.nationalId ?? '';
      _qiraatCtrl.text = p.qiraat ?? '';
    }
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _nationalIdCtrl,
      _qiraatCtrl
    ]) {
      c.addListener(() {
        if (!_hasChanges) setState(() => _hasChanges = true);
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    _qiraatCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ref.read(profileProvider.notifier).updateProfile(
            ProfileUpdateRequest(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim().isEmpty
                  ? null
                  : _phoneCtrl.text.trim(),
              nationalId: _nationalIdCtrl.text.trim().isEmpty
                  ? null
                  : _nationalIdCtrl.text.trim(),
              qiraat: _qiraatCtrl.text.trim().isEmpty
                  ? null
                  : _qiraatCtrl.text.trim(),
              profileImageFile: _selectedImage,
            ),
          );
    }
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? _eNavyMid : _eLightCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تجاهل التغييرات؟',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? _eCream : _eNavy)),
                const SizedBox(height: 10),
                Text('لديك تغييرات غير محفوظة. هل تريد تجاهلها؟',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: _eGold.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 11)),
                      child: Text('إلغاء',
                          style: TextStyle(
                              color: isDark ? _eCream : _eNavy,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          elevation: 0),
                      child: const Text('تجاهل',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
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
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvoked: (didPop) async {
          if (!didPop && _hasChanges) {
            final ok = await _confirmDiscard();
            if (ok && mounted) context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? _eNavy : _eLightBg,
          body: Stack(
            children: [
              Column(
                children: [
                  _EditTopBar(
                    isDark: isDark,
                    hasChanges: _hasChanges,
                    onBack: () async {
                      if (_hasChanges) {
                        final ok = await _confirmDiscard();
                        if (ok && mounted) context.pop();
                      } else {
                        context.pop();
                      }
                    },
                    onSave: _hasChanges ? _save : null,
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),

                            // ── Basic info section ─────────────────
                            _SectionLabel(
                                label: 'المعلومات الأساسية', isDark: isDark),
                            const SizedBox(height: 12),
                            _FormCard(
                              isDark: isDark,
                              children: [
                                _Field(
                                  controller: _nameCtrl,
                                  label: 'الاسم الكامل',
                                  icon: Icons.person_rounded,
                                  color: const Color(0xFF1565C0),
                                  isDark: isDark,
                                  validator: (v) => Validators.validateName(v),
                                  inputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                ),
                                _FormDivider(isDark: isDark),
                                _Field(
                                  controller: _emailCtrl,
                                  label: 'البريد الإلكتروني',
                                  icon: Icons.email_rounded,
                                  color: const Color(0xFFE65100),
                                  isDark: isDark,
                                  validator: (v) => Validators.validateEmail(v),
                                  inputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Additional info ─────────────────────
                            _SectionLabel(
                                label: 'معلومات إضافية', isDark: isDark),
                            const SizedBox(height: 12),
                            _FormCard(
                              isDark: isDark,
                              children: [
                                _Field(
                                  controller: _phoneCtrl,
                                  label: 'رقم الهاتف',
                                  icon: Icons.phone_rounded,
                                  color: const Color(0xFF2E7D32),
                                  isDark: isDark,
                                  validator: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      return Validators.validatePhone(v);
                                    }
                                    return null;
                                  },
                                  inputAction: TextInputAction.next,
                                  keyboardType: TextInputType.phone,
                                ),
                                _FormDivider(isDark: isDark),
                                _Field(
                                  controller: _nationalIdCtrl,
                                  label: 'رقم الهوية الوطنية',
                                  icon: Icons.credit_card_rounded,
                                  color: const Color(0xFF6A1B9A),
                                  isDark: isDark,
                                  inputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                                _FormDivider(isDark: isDark),
                                _Field(
                                  controller: _qiraatCtrl,
                                  label: 'القراءة',
                                  icon: Icons.menu_book_rounded,
                                  color: _eGold,
                                  isDark: isDark,
                                  inputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // ── Save button ─────────────────────────
                            _SaveButton(
                              isDark: isDark,
                              enabled: _hasChanges,
                              loading: profileState.isLoading,
                              onTap: _hasChanges ? _save : null,
                            ),
                          ],
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
                      child: CircularProgressIndicator(color: _eGold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _EditTopBar extends StatelessWidget {
  final bool isDark;
  final bool hasChanges;
  final VoidCallback onBack;
  final VoidCallback? onSave;
  const _EditTopBar({
    required this.isDark,
    required this.hasChanges,
    required this.onBack,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _eNavy],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Back
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('تعديل الملف الشخصي',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              // Save
              GestureDetector(
                onTap: onSave,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasChanges
                        ? _eGold.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasChanges
                          ? _eGold.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text('حفظ',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: hasChanges
                              ? _eGold
                              : Colors.white.withValues(alpha: 0.3))),
                ),
              ),
            ],
          ),
        ),
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
                  color: _eGold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? _eCream.withValues(alpha: 0.8)
                      : _eNavy.withValues(alpha: 0.7))),
        ],
      );
}

// ─── Form card container ──────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _FormCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: isDark ? _eNavyMid : _eLightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _eGold.withValues(alpha: 0.15)),
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
        child: Column(children: children),
      );
}

class _FormDivider extends StatelessWidget {
  final bool isDark;
  const _FormDivider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
      );
}

// ─── Individual field inside card ─────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String? Function(String?)? validator;
  final TextInputAction inputAction;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.inputAction,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _eCream : _eNavy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: inputAction,
      keyboardType: keyboardType,
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
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

// ─── Save button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isDark;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const _SaveButton({
    required this.isDark,
    required this.enabled,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [_eGold, Color(0xFFB8860B)],
                )
              : null,
          color: enabled ? null : (isDark ? _eNavyMid : Colors.grey[200]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _eGold.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded,
                        size: 18,
                        color: enabled
                            ? Colors.white
                            : (isDark ? Colors.grey[600] : Colors.grey[400])),
                    const SizedBox(width: 8),
                    Text('حفظ التغييرات',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: enabled
                                ? Colors.white
                                : (isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400]))),
                  ],
                ),
        ),
      ),
    );
  }
}
