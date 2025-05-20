class WorkoutModel {
  final String id;
  final String userId; // NUEVO
  final int minutes;
  final double distance;
  final double calories;
  final DateTime date;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.minutes,
    required this.distance,
    required this.calories,
    required this.date,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['\$id'],
        userId: json['userId'], // NUEVO
        minutes: json['minutes'],
        distance: json['distance'],
        calories: json['calories'],
        date: DateTime.parse(json['date']),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId, // NUEVO
        'minutes': minutes,
        'distance': distance,
        'calories': calories,
        'date': date.toIso8601String(),
      };
}
