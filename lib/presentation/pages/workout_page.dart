import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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

  final controller = Get.find<WorkoutController>();
  bool showOnlyLast7Days = false;

  @override
  void initState() {
    super.initState();
    _refreshWorkoutList();
  }

  void _refreshWorkoutList() async {
    try {
      await controller.fetchWorkouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Historial actualizado')),
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
        minutes: int.parse(_minutesController.text),
        distance: double.parse(_distanceController.text),
        calories: double.parse(_caloriesController.text),
        date: selectedDate.value!,
      );

      print("_submitWorkout");
      print(workout);

      controller.addWorkout(workout);
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
    final cutoff = now.subtract(Duration(days: 7));
    return controller.workouts
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Entrenamiento'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Actualizar historial',
            onPressed: _refreshWorkoutList,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Minutos'),
                  validator: (value) =>
                      value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 0
                          ? 'Minutos válidos requeridos'
                          : null,
                ),
                TextFormField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Distancia (m)'),
                  validator: (value) =>
                      value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) < 0
                          ? 'Distancia válida requerida'
                          : null,
                ),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Calorías'),
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
                    trailing: Icon(Icons.calendar_today),
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitWorkout,
                  child: Text('Registrar Entrenamiento'),
                ),
              ],
            ),
          ),
          Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Historial de Entrenamientos', style: TextStyle(fontSize: 18)),
              TextButton(
                onPressed: () {
                  setState(() => showOnlyLast7Days = !showOnlyLast7Days);
                },
                child: Text(showOnlyLast7Days ? 'Ver todo' : 'Últimos 7 días'),
              ),
            ],
          ),
          Obx(() {
            final workouts = _filteredWorkouts();
            if (controller.isLoading.value) return CircularProgressIndicator();
            if (workouts.isEmpty) return Text('No hay entrenamientos aún.');
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return Card(
                  child: ListTile(
                    title: Text(DateFormat('yyyy-MM-dd').format(w.date)),
                    subtitle: Text('Tiempo: ${w.minutes} min | Distancia: ${w.distance} m | Calorías: ${w.calories}'),
                  ),
                );
              },
            );
          }),
          SizedBox(height: 24),
          Text('Gráfico de Minutos por Día', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: Obx(() {
              final data = _generateBarChartData(_filteredWorkouts());
              return BarChart(
                BarChartData(
                  barGroups: data,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = _generateBarChartData(_filteredWorkouts()).asMap().keys.toList();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _filteredWorkouts().asMap().containsKey(value.toInt())
                                  ? DateFormat('MM/dd').format(_filteredWorkouts()[value.toInt()].date)
                                  : '',
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }
}
