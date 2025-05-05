import 'package:get/get.dart';
import 'package:users_auth/model/workout_model.dart';
import 'package:users_auth/data/repositories/workout_repository.dart';

class WorkoutController extends GetxController {
  final WorkoutRepository repository;

  RxList<WorkoutModel> workouts = <WorkoutModel>[].obs;
  RxBool isLoading = false.obs;

  WorkoutController({required this.repository});

  Future<void> fetchWorkouts() async {
  isLoading.value = true;
  try {
    final result = await repository.getWorkouts();
    print('✅ Entrenamientos obtenidos: ${result.length}');
    workouts.assignAll(result);
  } catch (e) {
    print('❌ Error al obtener entrenamientos: $e');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> addWorkout(WorkoutModel workout) async {
    await repository.addWorkout(workout);
    await fetchWorkouts(); // Refresh after add
  }
}
