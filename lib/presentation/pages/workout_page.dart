import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/workout_controller.dart';
import 'package:users_auth/model/workout_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final workoutController = Get.find<WorkoutController>();
  final authController = Get.find<AuthController>();
  bool showOnlyLast7Days = false;

  @override
  void initState() {
    super.initState();
    _refreshWorkoutList();
  }

  void _refreshWorkoutList() async {
    try {
      await workoutController.fetchWorkouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Historial actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar: $e')),
        );
      }
    }
  }

  void _submitWorkout() {
    if (_formKey.currentState!.validate() && selectedDate.value != null) {
      final workout = WorkoutModel(
        id: '',
        userId: '', // ← agrega esto para cumplir con el constructor
        minutes: int.parse(_minutesController.text),
        distance: double.parse(_distanceController.text),
        calories: double.parse(_caloriesController.text),
        date: selectedDate.value!,
      );

      workoutController.addWorkout(workout);
      _minutesController.clear();
      _distanceController.clear();
      _caloriesController.clear();
      selectedDate.value = null;

      Get.snackbar(
        '¡Buen trabajo!',
        'Entrenamiento guardado. Sigue nadando 💪',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
      );
    }
  }

  List<WorkoutModel> _filteredWorkouts() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));
    return workoutController.workouts
        .where((w) => !showOnlyLast7Days || w.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<BarChartGroupData> _generateBarChartData(List<WorkoutModel> workouts) {
    final Map<String, int> minutesPerDay = {};

    for (var w in workouts) {
      final key = DateFormat('MM/dd').format(w.date);
      minutesPerDay[key] = (minutesPerDay[key] ?? 0) + w.minutes;
    }

    final keys = minutesPerDay.keys.toList()..sort();
    return List.generate(
      keys.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: minutesPerDay[keys[index]]!.toDouble())
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }

  double _calculateMaxY(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) return 10;
    final maxMinutes = workouts.map((w) => w.minutes).reduce((a, b) => a > b ? a : b);
    final roundedUp = ((maxMinutes + 39) ~/ 40) * 40; // múltiplos de 40
    return roundedUp.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Entrenamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar historial',
            onPressed: _refreshWorkoutList,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final workouts = _filteredWorkouts();
        final chartData = _generateBarChartData(workouts);
        final maxY = _calculateMaxY(workouts);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👉 Formulario
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minutos'),
                      validator: (value) =>
                          value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 0
                              ? 'Minutos válidos requeridos'
                              : null,
                    ),
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Distancia (m)'),
                      validator: (value) =>
                          value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) < 0
                              ? 'Distancia válida requerida'
                              : null,
                    ),
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calorías'),
                      validator: (value) =>
                          value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) < 0
                              ? 'Calorías válidas requeridas'
                              : null,
                    ),
                    Obx(() {
                      return ListTile(
                        title: Text(selectedDate.value == null
                            ? 'Seleccionar Fecha'
                            : DateFormat('yyyy-MM-dd').format(selectedDate.value!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) selectedDate.value = date;
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submitWorkout,
                      child: const Text('Registrar Entrenamiento'),
                    ),
                  ],
                ),
              ),

              // 👉 Gráfico de barras
              const SizedBox(height: 24),
              const Text(
                'Gráfico de Minutos por Día',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 40,
                    ),
                    barGroups: chartData,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < workouts.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MM/dd').format(workouts[value.toInt()].date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 40,
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),

              // 👉 Historial
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Historial de Entrenamientos', style: TextStyle(fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      setState(() => showOnlyLast7Days = !showOnlyLast7Days);
                    },
                    child: Text(showOnlyLast7Days ? 'Ver todo' : 'Últimos 7 días'),
                  ),
                ],
              ),
              workoutController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : workouts.isEmpty
                      ? const Text('No hay entrenamientos aún.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: workouts.length,
                          itemBuilder: (context, index) {
                            final w = workouts[index];
                            return Card(
                              child: ListTile(
                                title: Text(DateFormat('yyyy-MM-dd').format(w.date)),
                                subtitle: Text(
                                  'Tiempo: ${w.minutes} min | Distancia: ${w.distance} m | Calorías: ${w.calories}',
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        );
      }),
    );
  }
}
