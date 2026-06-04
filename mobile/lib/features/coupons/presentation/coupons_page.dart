import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/agri_repository.dart';

class CouponsPage extends ConsumerWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_couponsProvider);
    final codeCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('优惠券')),
      body: data.when(
        data: (json) {
          final available = json['available'] as List? ?? [];
          final claimed = json['claimed'] as List? ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: '输入券码领取'),
              ),
              FilledButton(
                onPressed: () async {
                  await ref.read(agriRepositoryProvider).claimCoupon(codeCtrl.text.trim());
                  ref.invalidate(_couponsProvider);
                },
                child: const Text('领取'),
              ),
              const Text('可领取'),
              ...available.map((c) {
                final m = Map<String, dynamic>.from(c as Map);
                return ListTile(title: Text(m['title'] as String), subtitle: Text(m['code'] as String));
              }),
              const Text('已领取'),
              ...claimed.map((c) {
                final m = Map<String, dynamic>.from(c as Map);
                return ListTile(title: Text(m['title'] as String));
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _couponsProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).coupons());
