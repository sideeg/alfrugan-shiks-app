// Path: lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/presentation/screens/logs/logs_screen.dart';
import 'package:quran_sheikh_app/presentation/screens/profile/About_screen.dart';
import 'package:quran_sheikh_app/presentation/screens/profile/SupportScreen.dart';
import 'package:quran_sheikh_app/presentation/screens/profile/change_password_screen.dart';
import 'package:quran_sheikh_app/presentation/screens/profile/edit_profile_screen.dart';
import 'package:quran_sheikh_app/presentation/screens/profile/profile_screen.dart';
import '../../core/constants/route_constants.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/courses/course_details_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../../shared/widgets/common/scaffold_with_nav_bar.dart';
import '../../domain/entities/courses/course_entity.dart';
import '../screens/logs/enhanced_student_logs_screen.dart';
import '../screens/students/students_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      // ── Auth (no nav bar) ────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),

      // ── Main shell (with nav bar) ────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/courses',
            name: 'courses',
            builder: (_, __) => const CoursesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'courseDetails',
                builder: (_, state) {
                  final course = state.extra! as CourseEntity;
                  return CourseDetailsScreen(course: course);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/students',
            name: 'students',
            builder: (_, __) => const StudentsScreen(),
          ),

          // ── Student logs — inside shell so nav bar stays visible ──────────
          GoRoute(
            path: '/student-logs/:studentId/:studentName',
            name: 'studentLogs',
            builder: (context, state) {
              final studentId = int.parse(state.pathParameters['studentId']!);
              final studentName = state.pathParameters['studentName']!;
              final extra = state.extra as Map<String, dynamic>?;
              final courseId = extra?['courseId'] as int? ?? 1;
              final groupId = extra?['groupId'] as int? ?? 1;
              return EnhancedStudentLogsScreen(
                studentId: studentId,
                studentName: studentName,
                courseId: courseId,
                groupId: groupId,
              );
            },
          ),

          // ── Profile (now inside shell — shows nav bar) ────────────────────
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/change-password',
            name: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: '/support',
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: RouteConstants.LOGS,
            name: 'logs',
            builder: (context, state) => const LogsScreen(),
          ),
          GoRoute(
            path: RouteConstants.NOTIFICATIONS,
            name: 'notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsScreen(),
            ),
          ),
        ], // closes ShellRoute routes
      ), // closes ShellRoute
    ], // closes GoRouter routes
  ); // closes GoRouter
}
