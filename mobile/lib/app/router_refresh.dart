import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_provider.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _sub = _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription<AgriUser?> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
