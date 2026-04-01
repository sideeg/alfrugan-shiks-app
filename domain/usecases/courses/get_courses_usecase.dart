// Path: lib/domain/usecases/courses/get_courses_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/courses/course_entity.dart';
import '../../repositories/courses_repository.dart';

class GetCoursesUseCase implements UseCase<List<CourseEntity>, NoParams> {
  final CoursesRepository repository;

  GetCoursesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourseEntity>>> call(NoParams params) async {
    return await repository.getCourses();
  }
}

