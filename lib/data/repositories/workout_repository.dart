import 'package:appwrite/appwrite.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';
import 'package:users_auth/model/workout_model.dart';

class WorkoutRepository {
  final Databases databases;

  WorkoutRepository(this.databases);

  Future<void> addWorkout(WorkoutModel workout) async {
  await databases.createDocument(
    databaseId: AppwriteConstants.databaseId,
    collectionId: AppwriteConstants.workoutCollectionId,
    documentId: ID.unique(),
    data: workout.toJson(),
    permissions: [
      Permission.read(Role.user('current')),
      Permission.update(Role.user('current')),
      Permission.delete(Role.user('current')),
    ],
  );
}


  Future<List<WorkoutModel>> getWorkouts() async {
    final response = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.workoutCollectionId,
    );
    return response.documents
        .map((doc) => WorkoutModel.fromJson(doc.data))
        .toList();
  }
}
