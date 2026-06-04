import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/agri_repository.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_orderDetailProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情')),
      body: detail.when(
        data: (d) {
          final o = d.order;
          final children = d.children;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('类型: ${o.orderType}'),
              Text('状态: ${o.status}'),
              Text('金额: ¥${o.totalAmount}'),
              if (o.coldChainFee > 0) Text('冷链费: ¥${o.coldChainFee}'),
              if (o.orderType == 'presale_balance' && o.status == 'pending_payment')
                FilledButton(
                  onPressed: () async {
                    await ref.read(agriRepositoryProvider).payBalance(o.id);
                    ref.invalidate(_orderDetailProvider(orderId));
                  },
                  child: const Text('支付尾款 Mock'),
                ),
              if (children.isNotEmpty) ...[
                const Divider(),
                const Text('关联订单'),
                ...children.map((c) => ListTile(
                      title: Text(c.orderType),
                      subtitle: Text('${c.status} · ¥${c.totalAmount}'),
                    )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _orderDetailProvider = FutureProvider.family(
  (ref, String id) => ref.read(agriRepositoryProvider).orderDetail(id),
);
