// Path: lib/data/repositories/courses_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/entities/courses/course_entity.dart';
import '../../domain/repositories/courses_repository.dart';
import '../datasources/remote/courses_remote_datasource.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesRemoteDataSource remoteDataSource;

  CoursesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses() async {
    try {
      final courses = await remoteDataSource.getCourses();
      return Right(courses.cast<CourseEntity>());
    } catch (e) {
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseDetails(int courseId) async {
    try {
      final course = await remoteDataSource.getCourseDetails(courseId);
      return Right(course as CourseEntity);
    } catch (e) {
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }
}
