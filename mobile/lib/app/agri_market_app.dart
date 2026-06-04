import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

class AgriMarketApp extends ConsumerWidget {
  const AgriMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '农品溯源',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      routerConfig: router,
    );
  }
}
