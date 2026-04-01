// Path: lib/presentation/screens/profile/profile_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';
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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).getProfile().then((_) {
        if (mounted) _fadeCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'ش';
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _navy : _lightBg,
        body: Stack(
          children: [
            RefreshIndicator(
              color: _gold,
              backgroundColor: isDark ? _navyMid : _lightCard,
              onRefresh: () => ref.read(profileProvider.notifier).getProfile(),
              child: profileState.profile == null && !profileState.isLoading
                  ? _ErrorState(
                      isDark: isDark,
                      onRetry: () =>
                          ref.read(profileProvider.notifier).getProfile())
                  : profileState.profile != null
                      ? FadeTransition(
                          opacity: _fade,
                          child: _ProfileContent(
                            profile: profileState.profile!,
                            isDark: isDark,
                            initials: _initials(profileState.profile!.name),
                            onLogout: () => _showLogoutDialog(isDark),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
            if (profileState.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(color: _gold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDark ? _navyMid : _lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 28, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 16),
              Text('تسجيل الخروج',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? _cream : _navy)),
              const SizedBox(height: 8),
              Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _gold.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('إلغاء',
                          style: TextStyle(
                              color: isDark ? _cream : _navy,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('خروج',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main scrollable content ──────────────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final dynamic profile;
  final bool isDark;
  final String initials;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.profile,
    required this.isDark,
    required this.initials,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Hero header ──────────────────────────────────────
          _HeroHeader(
            profile: profile,
            isDark: isDark,
            initials: initials,
            onEdit: () => context.push('/profile/edit'),
          ),

          const SizedBox(height: 20),

          // ── Personal info ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _InfoCard(
                  title: 'المعلومات الشخصية',
                  icon: Icons.person_rounded,
                  isDark: isDark,
                  rows: [
                    _InfoRow(label: 'الاسم', value: profile.name),
                    _InfoRow(label: 'البريد الإلكتروني', value: profile.email),
                    if (profile.phone != null)
                      _InfoRow(label: 'رقم الهاتف', value: profile.phone!),
                    if (profile.nationalId != null)
                      _InfoRow(label: 'رقم الهوية', value: profile.nationalId!),
                    if (profile.qiraat != null)
                      _InfoRow(label: 'القراءة', value: profile.qiraat!),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Account settings ─────────────────────────
                _MenuCard(
                  title: 'إعدادات الحساب',
                  icon: Icons.manage_accounts_rounded,
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF1565C0),
                      label: 'تعديل الملف الشخصي',
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _MenuItem(
                      icon: Icons.lock_rounded,
                      color: const Color(0xFF6A1B9A),
                      label: 'تغيير كلمة المرور',
                      onTap: () => context.push('/profile/change-password'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_rounded,
                      color: const Color(0xFFE65100),
                      label: 'الإشعارات',
                      onTap: () => context.push('/profile/notifications'),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── App settings ─────────────────────────────
                _MenuCard(
                  title: 'إعدادات التطبيق',
                  icon: Icons.settings_rounded,
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.language_rounded,
                      color: const Color(0xFF00838F),
                      label: 'اللغة',
                      trailing: Text('العربية',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[500])),
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF2E7D32),
                      label: 'المساعدة والدعم',
                      onTap: () => context.push('/support'),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      color: _goldDeep,
                      label: 'حول التطبيق',
                      onTap: () => context.push('/about'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Logout ────────────────────────────────────
                _LogoutButton(isDark: isDark, onTap: onLogout),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final dynamic profile;
  final bool isDark;
  final String initials;
  final VoidCallback onEdit;

  const _HeroHeader({
    required this.profile,
    required this.isDark,
    required this.initials,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
      ),
      child: Stack(
        children: [
          // Geometric star background
          Positioned(
            right: -40,
            top: -40,
            child: CustomPaint(
              size: const Size(180, 180),
              painter: _StarBg(color: _gold.withValues(alpha: 0.05)),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 0,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _StarBg(color: _gold.withValues(alpha: 0.04)),
            ),
          ),
          // Bismillah ornament top
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
                    _gold.withValues(alpha: 0.0),
                    _gold,
                    _gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  // Top row: title + edit button
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/dashboard'),
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
                      Text('الملف الشخصي',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _cream.withValues(alpha: 0.9))),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _gold.withValues(alpha: 0.35)),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 16, color: _gold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer gold ring
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _gold.withValues(alpha: 0.4), width: 2),
                        ),
                      ),
                      // Inner ring
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _gold.withValues(alpha: 0.15), width: 1),
                        ),
                      ),
                      // Avatar circle
                      Container(
                        width: 78,
                        height: 78,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2A4A7C), _navyLight],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _gold,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3),
                    textDirection: TextDirection.rtl,
                  ),

                  const SizedBox(height: 6),

                  // Email
                  Text(
                    profile.email,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.55)),
                  ),

                  const SizedBox(height: 12),

                  // Role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded,
                            size: 13, color: _gold),
                        const SizedBox(width: 6),
                        const Text('شيخ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _gold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gold ornamental divider
                  Row(children: [
                    Expanded(
                        child: Container(
                            height: 1, color: _gold.withValues(alpha: 0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _gold.withValues(alpha: 0.6))),
                    ),
                    Expanded(
                        child: Container(
                            height: 1, color: _gold.withValues(alpha: 0.2))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: _gold),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textClr)),
              ],
            ),
          ),
          Container(
              height: 1,
              color: _gold.withValues(alpha: 0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16)),
          // Rows
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return _buildRow(e.value, isLast, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildRow(_InfoRow row, bool isLast, bool isDark) {
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Gold dot
              Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.6))),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: Text(row.label,
                    style: TextStyle(
                        fontSize: 12,
                        color: subClr,
                        fontWeight: FontWeight.w500),
                    textDirection: TextDirection.rtl),
              ),
              Expanded(
                child: Text(row.value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textClr),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04)),
      ],
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

// ─── Menu card ────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<_MenuItem> items;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: _gold),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textClr)),
              ],
            ),
          ),
          Container(
              height: 1,
              color: _gold.withValues(alpha: 0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16)),
          // Items
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return _buildItem(e.value, isLast, isDark, context);
          }),
        ],
      ),
    );
  }

  Widget _buildItem(
      _MenuItem item, bool isLast, bool isDark, BuildContext ctx) {
    final textClr = isDark ? _cream : _navy;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: isLast
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18))
                : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Coloured icon badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textClr),
                        textDirection: TextDirection.rtl),
                  ),
                  if (item.trailing != null) ...[
                    item.trailing!,
                    const SizedBox(width: 6),
                  ],
                  Icon(Icons.arrow_back_ios_rounded,
                      size: 13,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04)),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    this.trailing,
    required this.onTap,
  });
}

// ─── Logout button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _LogoutButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              const Color(0xFFE53935).withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                size: 18, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            const Text('تسجيل الخروج',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935))),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  size: 34, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 20),
            Text('فشل في تحميل البيانات',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy)),
            const SizedBox(height: 8),
            Text('اسحب للأسفل للمحاولة مرة أخرى',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[500]),
                textDirection: TextDirection.rtl),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
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
