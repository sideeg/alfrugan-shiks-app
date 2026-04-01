// Path: lib/presentation/screens/logs/widgets/enhanced_log_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/domain/entities/hifz_log_entity.dart';
import 'package:quran_sheikh_app/domain/entities/review_log_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';
import 'package:quran_sheikh_app/presentation/providers/logs_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _hifzClr = Color(0xFF2E7D32);
const _revClr = Color(0xFF1565C0);

enum LogType { hifz, review }

// Evaluation options — must match DB enum exactly:
// ['excellent', 'very_good', 'good', 'needs_improvement', 'poor']
const _evals = [
  ('excellent', 'ممتاز', '★★★★★', Color(0xFF2E7D32)),
  ('very_good', 'جيد جداً', '★★★★☆', Color(0xFF1565C0)),
  ('good', 'جيد', '★★★☆☆', Color(0xFFF57F17)),
  ('needs_improvement', 'يحتاج تحسين', '★★☆☆☆', Color(0xFFE65100)),
  ('poor', 'ضعيف', '★☆☆☆☆', Color(0xFFC62828)),
];

class EnhancedLogSheet extends ConsumerStatefulWidget {
  final int studentId;
  final int courseId;
  final int groupId;
  final HifzLogEntity? hifzLog;
  final ReviewLogEntity? reviewLog;
  final LogType initialLogType;

  const EnhancedLogSheet({
    required this.studentId,
    required this.courseId,
    required this.groupId,
    this.hifzLog,
    this.reviewLog,
    this.initialLogType = LogType.hifz,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedLogSheet> createState() => _EnhancedLogSheetState();
}

class _EnhancedLogSheetState extends ConsumerState<EnhancedLogSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startS, _endS, _startA, _endA, _notes;
  late LogType _type;
  String _eval = 'very_good';
  bool _loading = false;

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  bool get _isEdit => widget.hifzLog != null || widget.reviewLog != null;

  @override
  void initState() {
    super.initState();
    _type = widget.initialLogType;
    final h = widget.hifzLog;
    final r = widget.reviewLog;
    _startS = TextEditingController(text: h?.startSurah ?? r?.startSurah ?? '');
    _endS = TextEditingController(text: h?.endSurah ?? r?.endSurah ?? '');
    _startA = TextEditingController(
        text: h?.startAyah.toString() ?? r?.startAyah.toString() ?? '');
    _endA = TextEditingController(
        text: h?.endAyah.toString() ?? r?.endAyah.toString() ?? '');
    _notes = TextEditingController(text: h?.notes ?? r?.notes ?? '');
    _eval = h?.evaluation ?? r?.evaluation ?? 'very_good';

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _startS.dispose();
    _endS.dispose();
    _startA.dispose();
    _endA.dispose();
    _notes.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final body = {
        'student_id': widget.studentId,
        'group_id': widget.groupId,
        'course_id': widget.courseId,
        'sheikh_id': ref.read(authProvider).user?.id,
        'start_surah': _startS.text.trim(),
        'end_surah': _endS.text.trim(),
        'start_ayah': int.parse(_startA.text.trim()),
        'end_ayah': int.parse(_endA.text.trim()),
        'evaluation': _eval,
        'notes': _notes.text.trim(),
      };

      if (_type == LogType.hifz) {
        widget.hifzLog == null
            ? await addHifzLog(ref, body)
            : await updateHifzLog(ref, widget.hifzLog!.id, body);
      } else {
        widget.reviewLog == null
            ? await addReviewLog(ref, body)
            : await updateReviewLog(ref, widget.reviewLog!.id, body);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_type == LogType.hifz
              ? 'تم حفظ سجل التسميع بنجاح ✓'
              : 'تم حفظ سجل المراجعة بنجاح ✓'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color get _activeColor => _type == LogType.hifz ? _hifzClr : _revClr;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? _navyMid : Colors.white;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Sheet header (fixed) ───────────────────────────
            _SheetHeader(
              isDark: isDark,
              isEdit: _isEdit,
              type: _type,
              activeColor: _activeColor,
              onTypeChange: _isEdit ? null : (t) => setState(() => _type = t),
            ),
            // ── Scrollable form ────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),

                      // ── Surah fields ─────────────────────────
                      _SectionLabel(
                          label: 'نطاق السورة والآيات', isDark: isDark),
                      const SizedBox(height: 10),
                      _FieldCard(
                        isDark: isDark,
                        children: [
                          _SheetField(
                            ctrl: _startS,
                            label: 'السورة البداية',
                            icon: Icons.first_page_rounded,
                            color: _activeColor,
                            isDark: isDark,
                            action: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'هذا الحقل مطلوب'
                                : null,
                          ),
                          _FieldDivider(isDark: isDark),
                          _SheetField(
                            ctrl: _endS,
                            label: 'السورة النهاية',
                            icon: Icons.last_page_rounded,
                            color: _activeColor,
                            isDark: isDark,
                            action: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'هذا الحقل مطلوب'
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Ayah numbers ──────────────────────────
                      Row(children: [
                        Expanded(
                          child: _FieldCard(
                            isDark: isDark,
                            children: [
                              _SheetField(
                                ctrl: _startA,
                                label: 'الآية البداية',
                                icon: Icons.looks_one_rounded,
                                color: _activeColor,
                                isDark: isDark,
                                action: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FieldCard(
                            isDark: isDark,
                            children: [
                              _SheetField(
                                ctrl: _endA,
                                label: 'الآية النهاية',
                                icon: Icons.looks_two_rounded,
                                color: _activeColor,
                                isDark: isDark,
                                action: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                              ),
                            ],
                          ),
                        ),
                      ]),

                      const SizedBox(height: 18),

                      // ── Evaluation ────────────────────────────
                      _SectionLabel(label: 'التقييم', isDark: isDark),
                      const SizedBox(height: 10),
                      _EvalSelector(
                        isDark: isDark,
                        selected: _eval,
                        onSelect: (v) => setState(() => _eval = v),
                      ),

                      const SizedBox(height: 18),

                      // ── Notes ─────────────────────────────────
                      _SectionLabel(label: 'ملاحظات (اختياري)', isDark: isDark),
                      const SizedBox(height: 10),
                      _FieldCard(
                        isDark: isDark,
                        children: [
                          _SheetField(
                            ctrl: _notes,
                            label: 'اكتب ملاحظاتك هنا...',
                            icon: Icons.notes_rounded,
                            color: _gold,
                            isDark: isDark,
                            action: TextInputAction.done,
                            maxLines: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // ── Save button ───────────────────────────
                      _SaveBtn(
                        isDark: isDark,
                        loading: _loading,
                        color: _activeColor,
                        label: _isEdit
                            ? 'حفظ التعديلات'
                            : 'حفظ ${_type == LogType.hifz ? 'التسميع' : 'المراجعة'}',
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet header ──────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final bool isDark, isEdit;
  final LogType type;
  final Color activeColor;
  final void Function(LogType)? onTypeChange;

  const _SheetHeader({
    required this.isDark,
    required this.isEdit,
    required this.type,
    required this.activeColor,
    this.onTypeChange,
  });

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _cream : _navy;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark ? [_navyMid, _navyMid] : [Colors.white, Colors.white],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title row
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? _navyLight
                          : Colors.grey.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ),
                // Title + icon
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.add_circle_rounded,
                        size: 18,
                        color: activeColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit ? 'تعديل السجل' : 'إضافة سجل جديد',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textClr),
                    ),
                  ],
                ),
              ],
            ),

            // Type toggle (only when adding new)
            if (!isEdit) ...[
              const SizedBox(height: 16),
              _TypeToggle(
                isDark: isDark,
                type: type,
                onTypeChange: onTypeChange!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Type toggle ──────────────────────────────────────────────────────────────
class _TypeToggle extends StatelessWidget {
  final bool isDark;
  final LogType type;
  final void Function(LogType) onTypeChange;

  const _TypeToggle({
    required this.isDark,
    required this.type,
    required this.onTypeChange,
  });

  @override
  Widget build(BuildContext context) {
    final bgBase = isDark
        ? _navyLight.withValues(alpha: 0.8)
        : Colors.grey.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _TypeOption(
            label: 'تسميع',
            icon: Icons.menu_book_rounded,
            selected: type == LogType.hifz,
            color: _hifzClr,
            isDark: isDark,
            onTap: () => onTypeChange(LogType.hifz),
          ),
          const SizedBox(width: 4),
          _TypeOption(
            label: 'مراجعة',
            icon: Icons.refresh_rounded,
            selected: type == LogType.review,
            color: _revClr,
            isDark: isDark,
            onTap: () => onTypeChange(LogType.review),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected, isDark;
  final Color color;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 15,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.grey[500] : Colors.grey[400])),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.grey[500] : Colors.grey[500]))),
              ],
            ),
          ),
        ),
      );
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
              height: 12,
              decoration: BoxDecoration(
                  color: _gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? _cream.withValues(alpha: 0.7)
                      : _navy.withValues(alpha: 0.65))),
        ],
      );
}

// ─── Field card container ─────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _FieldCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: isDark ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

class _FieldDivider extends StatelessWidget {
  final bool isDark;
  const _FieldDivider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
      );
}

// ─── Individual sheet text field ──────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final TextInputAction action;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.action,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return TextFormField(
      controller: ctrl,
      textInputAction: action,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      textDirection: TextDirection.rtl,
      style:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textClr),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: subClr),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        errorStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}

// ─── Visual evaluation selector ───────────────────────────────────────────────
class _EvalSelector extends StatelessWidget {
  final bool isDark;
  final String selected;
  final void Function(String) onSelect;

  const _EvalSelector({
    required this.isDark,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _evals.map((e) {
        final key = e.$1;
        final label = e.$2;
        final stars = e.$3;
        final color = e.$4;
        final isSelected = selected == key;

        return GestureDetector(
          onTap: () => onSelect(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.15 : 0.08)
                  : (isDark ? _navy : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : _gold.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Animated select indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                // Label
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? _cream : _navy)
                              : (isDark ? Colors.grey[400] : Colors.grey[600])),
                      textDirection: TextDirection.rtl),
                ),
                // Stars
                Text(stars,
                    style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? color
                            : (isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Save button ──────────────────────────────────────────────────────────────
class _SaveBtn extends StatefulWidget {
  final bool isDark, loading;
  final Color color;
  final String label;
  final Future<void> Function() onTap;

  const _SaveBtn({
    required this.isDark,
    required this.loading,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SaveBtn> createState() => _SaveBtnState();
}

class _SaveBtnState extends State<_SaveBtn>
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
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                widget.color,
                widget.color.withValues(alpha: 0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded,
                          size: 17, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(widget.label,
                          style: const TextStyle(
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
