import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marafinal/features/auth/domain/entities/app_user.dart';
import 'package:marafinal/features/auth/domain/repos/auth_repo.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class FireBaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AppUser?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email! Check your inbox.";
    } catch (e) {
      return "An error occurred while trying to send the password reset email.";
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) throw Exception('No user is currently signed in.');

      await user?.delete();

      await logout();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  @override
  Future<AppUser?> signInWithApple() async {
    // TODO: implement signInWithApple
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        oAuthCredential,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
      );

      return appUser;
    } catch (e) {
      print("Error during Apple Sign-In: $e");
      return null;
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      return appUser;
    } catch (e) {
      print(e);
      return null;
    }
  }


}
