import 'package:get/get.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  AuthController(this._authRepository);

  Future<bool> checkAuth() async {
    isLoading.value = true;
    try {
      return await _authRepository.isLoggedIn();
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _authRepository.login(email: email, password: password);
      Get.offAllNamed('/WorkoutPage');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _authRepository.createAccount(
        email: email,
        password: password,
        name: name,
      );
      await login(email, password);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      Get.offAllNamed('/LoginPage');
    } catch (e) {
      error.value = e.toString();
    }
  }
}
