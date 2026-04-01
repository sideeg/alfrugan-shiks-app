// Path: lib/domain/repositories/courses_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/courses/course_entity.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses();
  Future<Either<Failure, CourseEntity>> getCourseDetails(int courseId);
}

