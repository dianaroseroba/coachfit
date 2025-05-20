import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';

import 'package:users_auth/core/config/app_config.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';
import 'package:users_auth/data/repositories/workout_repository.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/workout_controller.dart';

import 'package:users_auth/presentation/pages/splash_page.dart';
import 'package:users_auth/presentation/pages/login_page.dart';
import 'package:users_auth/presentation/pages/register_page.dart';
import 'package:users_auth/presentation/pages/workout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = AppwriteConfig.initClient();
  final account = Account(client);
  
  final databases = Databases(client);

  Get.put<Account>(account); // ← REGISTRA LA INSTANCIA
// Inyectamos las dependencias
  Get.put(AuthRepository(account));
  Get.put(AuthController(Get.find<AuthRepository>()));

  Get.put(WorkoutRepository(databases));
  Get.put(WorkoutController(repository: Get.find<WorkoutRepository>()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Entrenamientos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/LoginPage', page: () => LoginPage()),
        GetPage(name: '/RegisterPage', page: () => RegisterPage()),
        GetPage(name: '/WorkoutPage', page: () => const WorkoutPage()),
      ],
    );
  }
}
