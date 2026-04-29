// lib/presentation/screens/students/students_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/domain/entities/student_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/students_provider.dart';
import 'package:quran_sheikh_app/presentation/screens/logs/enhanced_student_logs_screen.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('طلابي'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: isDark ? 0 : 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'البحث عن طالب، مجموعة أو دورة...',
                    hintStyle: TextStyle(
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  onChanged: (query) {
                    ref.read(searchQueryProvider.notifier).state = query;
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list), text: 'قائمة الطلاب'),
                  Tab(icon: Icon(Icons.school), text: 'حسب الدورة'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    isDark ? Colors.grey.shade500 : Colors.grey,
                indicatorColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      body: studentsAsync.when(
        data: (response) => Column(
          children: [
            _buildStatsHeader(response, isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStudentsList(),
                  _buildStudentsGrouped(),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString(), isDark),
      ),
    );
  }

  Widget _buildStatsHeader(StudentsResponse response, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'إجمالي الطلاب',
              response.totalStudents.toString(),
              Colors.blue,
              Icons.person,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey.shade700 : Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'المجموعات',
              response.totalGroups.toString(),
              Colors.green,
              Icons.group,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey.shade700 : Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'الطلاب النشطين',
              ref.watch(filteredStudentsProvider).length.toString(),
              Colors.orange,
              Icons.trending_up,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, Color color, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentsList() {
    final filteredStudents = ref.watch(filteredStudentsProvider);
    if (filteredStudents.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(studentsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          return StudentCard(
            student: filteredStudents[index],
            onTap: () => _navigateToStudentLogs(filteredStudents[index]),
          );
        },
      ),
    );
  }

  Widget _buildStudentsGrouped() {
    final groupedStudents = ref.watch(studentsGroupedByCourseProvider);
    if (groupedStudents.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(studentsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedStudents.keys.length,
        itemBuilder: (context, index) {
          final courseName = groupedStudents.keys.elementAt(index);
          final students = groupedStudents[courseName]!;
          return CourseGroupCard(
            courseName: courseName,
            students: students,
            onStudentTap: _navigateToStudentLogs,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير كلمات البحث',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(studentsProvider),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _navigateToStudentLogs(StudentEntity student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedStudentLogsScreen(
          studentId: student.id,
          studentName: student.name,
          groupId: student.group.id,
          courseId: student.course.id,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class StudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;

  const StudentCard({required this.student, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 1 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
                child: Text(
                  student.name.isNotEmpty
                      ? student.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: _buildInfoChip(
                              student.course.name, Colors.blue, isDark),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: _buildInfoChip(
                              student.group.name, Colors.green, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? color.withOpacity(0.9) : color,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COURSE GROUP CARD
// ─────────────────────────────────────────────────────────────────────────────

class CourseGroupCard extends StatelessWidget {
  final String courseName;
  final List<StudentEntity> students;
  final Function(StudentEntity) onStudentTap;

  const CourseGroupCard({
    required this.courseName,
    required this.students,
    required this.onStudentTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 1 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          courseName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${students.length} طلاب',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
          child: Icon(Icons.school,
              color: isDark ? Colors.blue.shade300 : Colors.blue),
        ),
        children: students.map((student) {
          return ListTile(
            title: Text(
              student.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              student.group.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
              child: Text(
                student.name.isNotEmpty
                    ? student.name.substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                ),
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 14, color: isDark ? Colors.grey.shade600 : Colors.grey),
            onTap: () => onStudentTap(student),
          );
        }).toList(),
      ),
    );
  }
}
