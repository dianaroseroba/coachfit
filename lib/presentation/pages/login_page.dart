import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:users_auth/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (authController.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: const Text('Iniciar Sesión'),
                );
              }),
              TextButton(
                onPressed: () => Get.toNamed('/RegisterPage'),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              Obx(() {
                if (authController.error.value.isNotEmpty) {
                  return Text(
                    authController.error.value,
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
