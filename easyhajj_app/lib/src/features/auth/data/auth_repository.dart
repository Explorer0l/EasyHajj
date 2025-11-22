import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/app_user.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<void> signInWithGoogle();

  Future<void> signInAsGuest();

  Future<String> startPhoneNumberVerification(String phoneNumber);

  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitFuture;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw AuthException('Не удалось получить токен Google');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      throw AuthException(
        error.description ?? 'Google не смог авторизовать',
      );
    } on UnsupportedError catch (error) {
      throw AuthException(error.message ?? 'Платформа не поддерживает Google');
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Не удалось выполнить вход');
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    _googleInitFuture ??= _googleSignIn.initialize();
    await _googleInitFuture;
  }

  @override
  Future<void> signInAsGuest() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Гостевой вход временно недоступен');
    }
  }

  @override
  Future<String> startPhoneNumberVerification(String phoneNumber) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete('');
          }
        } on FirebaseAuthException catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(error.message ?? 'Не удалось завершить вход'),
            );
          }
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            AuthException(error.message ?? 'Ошибка подтверждения номера'),
          );
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Неверный код подтверждения');
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

