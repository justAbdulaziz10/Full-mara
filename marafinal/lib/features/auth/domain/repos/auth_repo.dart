import '../entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword(String email, String password);
  Future<AppUser?> registerWithEmailAndPassword(String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithApple();
}
