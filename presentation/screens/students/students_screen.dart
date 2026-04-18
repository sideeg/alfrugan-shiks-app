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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('طلابي'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          // FIX 1: Use 120 instead of 100 — gives enough room for search
          // bar (56px) + tabs (48px) + vertical padding (16px) = 120px
          preferredSize: const Size.fromHeight(120),
          child: Column(
            mainAxisSize: MainAxisSize.min, // don't expand beyond content
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'البحث عن طالب، مجموعة أو دورة...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true, // reduces internal padding
                  ),
                  onChanged: (query) {
                    ref.read(searchQueryProvider.notifier).state = query;
                  },
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list), text: 'قائمة الطلاب'),
                  Tab(icon: Icon(Icons.school), text: 'حسب الدورة'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      body: studentsAsync.when(
        data: (response) => Column(
          children: [
            _buildStatsHeader(response),
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
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildStatsHeader(StudentsResponse response) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: _buildStatItem(
              'المجموعات',
              response.totalGroups.toString(),
              Colors.green,
              Icons.group,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: _buildStatItem(
              'الطلاب النشطين',
              ref.watch(filteredStudentsProvider).length.toString(),
              Colors.orange,
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, Color color, IconData icon) {
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير كلمات البحث',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            style: TextStyle(color: Colors.grey[600]),
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
// FIX 2: All text fields use overflow: TextOverflow.ellipsis and the chips
// row uses Flexible so long emails and course names never overflow the card.
// ─────────────────────────────────────────────────────────────────────────────

class StudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;

  const StudentCard({required this.student, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  student.name.isNotEmpty
                      ? student.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Student info — Expanded prevents overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),

                    // Email — ellipsis prevents horizontal overflow
                    Text(
                      student.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),

                    // Chips row — Flexible allows chips to shrink if needed
                    Row(
                      children: [
                        Flexible(
                          child:
                              _buildInfoChip(student.course.name, Colors.blue),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child:
                              _buildInfoChip(student.group.name, Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COURSE GROUP CARD (unchanged — no overflow issues here)
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          courseName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${students.length} طلاب'),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.school, color: Colors.blue),
        ),
        children: students.map((student) {
          return ListTile(
            title: Text(student.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(student.group.name, overflow: TextOverflow.ellipsis),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Text(
                student.name.isNotEmpty
                    ? student.name.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => onStudentTap(student),
          );
        }).toList(),
      ),
    );
  }
}
