import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncData(null));

  final AuthRepository _repository;

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signInWithGoogle);
  }

  Future<void> continueAsGuest() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signInAsGuest);
  }

  Future<String> requestPhoneCode(String phoneNumber) async {
    state = const AsyncLoading();
    try {
      final verificationId =
          await _repository.startPhoneNumberVerification(phoneNumber);
      state = const AsyncData(null);
      return verificationId;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.confirmSmsCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

