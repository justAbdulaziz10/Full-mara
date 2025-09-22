import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/auth/domain/entities/app_user.dart';
import 'package:marafinal/features/auth/domain/repos/auth_repo.dart';
import 'package:marafinal/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  AppUser? get currentUser => _currentUser;

  void checkAuth() async {
    emit(AuthLoading());

    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password, ) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailAndPassword(email, password);

      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> register(String name, String email, String password) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailAndPassword(email, password);

      if(user!=null){
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async{
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  Future<String> forgotPassword(String email) async {
    try {
      final message = await authRepo.sendPasswordResetEmail(email) as String;
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithApple() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.signInWithApple();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }



}
