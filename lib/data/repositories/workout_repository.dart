import 'package:appwrite/appwrite.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';
import 'package:users_auth/model/workout_model.dart';
import 'package:get/get.dart';

class WorkoutRepository {
  final Databases databases;

  WorkoutRepository(this.databases);

  Future<void> addWorkout(WorkoutModel workout) async {
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.workoutCollectionId,
      documentId: ID.unique(),
      data: workout.toJson(),
    );
  }

  Future<List<WorkoutModel>> getWorkouts() async {
    final account = Get.find<Account>();
    final user = await account.get();

    final response = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.workoutCollectionId,
      queries: [
        Query.equal('userId', user.$id), // 🔐 Filtra por usuario logueado
      ],
    );

    return response.documents
        .map((doc) => WorkoutModel.fromJson(doc.data))
        .toList();
  }
}
