import 'package:get/get.dart';
import 'package:users_auth/model/workout_model.dart';
import 'package:users_auth/data/repositories/workout_repository.dart';
import 'package:appwrite/appwrite.dart';

class WorkoutController extends GetxController {
  final WorkoutRepository repository;

  RxList<WorkoutModel> workouts = <WorkoutModel>[].obs;
  RxBool isLoading = false.obs;

  WorkoutController({required this.repository});

  /// Consulta los entrenamientos del usuario logueado
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

  /// Agrega un nuevo entrenamiento para el usuario logueado
  Future<void> addWorkout(WorkoutModel workout) async {
    print("method addWorkout");
    print(workout);

    try {
      final account = Get.find<Account>();
      final user = await account.get(); // obtiene el usuario logueado

      final updatedWorkout = WorkoutModel(
        id: '',
        userId: user.$id, // ASIGNA el ID del usuario actual
        minutes: workout.minutes,
        distance: workout.distance,
        calories: workout.calories,
        date: workout.date,
      );

      await repository.addWorkout(updatedWorkout);
      await fetchWorkouts(); // Actualiza lista
    } catch (e) {
      print('❌ Error al agregar entrenamiento: $e');
    }
  }
}
