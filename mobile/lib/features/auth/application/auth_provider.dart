import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/agri_repository.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);

final authProvider = StateNotifierProvider<AuthNotifier, AgriUser?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AgriUser?> {
  AuthNotifier(this._ref) : super(null) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    final token = await _ref.read(tokenStorageProvider).read();
    if (token == null) return;
    _ref.read(authTokenProvider.notifier).state = token;
    try {
      final user = await _ref.read(agriRepositoryProvider).me();
      state = user;
    } catch (_) {
      await _ref.read(tokenStorageProvider).clear();
      _ref.read(authTokenProvider.notifier).state = null;
    }
  }

  Future<void> login(String phone, String password) async {
    final repo = _ref.read(agriRepositoryProvider);
    final result = await repo.login(phone, password);
    await _ref.read(tokenStorageProvider).write(result.token);
    _ref.read(authTokenProvider.notifier).state = result.token;
    state = result.user;
  }

  Future<void> logout() async {
    try {
      await _ref.read(agriRepositoryProvider).logout();
    } catch (_) {
      // ignore
    }
    await _ref.read(tokenStorageProvider).clear();
    _ref.read(authTokenProvider.notifier).state = null;
    state = null;
  }
}
