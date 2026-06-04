import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/agri_repository.dart';

class PresaleDetailPage extends ConsumerWidget {
  const PresaleDetailPage({super.key, required this.presaleId});
  final String presaleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presale = ref.watch(_presaleProvider(presaleId));
    return Scaffold(
      appBar: AppBar(title: const Text('预售详情')),
      body: presale.when(
        data: (p) {
          final deposit = (p['full_price'] as num) * (p['deposit_rate'] as num);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['title'] as String? ?? '', style: Theme.of(context).textTheme.headlineSmall),
                Text('全款 ¥${p['full_price']}'),
                Text('定金 20%: ¥$deposit'),
                Text('尾款提醒: 到货前 3 天 (${p['balance_due_at']})'),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    final order = await ref.read(agriRepositoryProvider).presaleDeposit(presaleId);
                    await ref.read(agriRepositoryProvider).payOrder(order.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('定金已支付，尾款单已生成')),
                      );
                    }
                  },
                  child: const Text('支付定金 Mock'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _presaleProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, id) => ref.read(agriRepositoryProvider).presale(id),
);
