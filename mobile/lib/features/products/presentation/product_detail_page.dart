import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/repositories/agri_repository.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_detailProvider(productId));
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: detail.when(
        data: (d) {
          final p = d.product;
          final batches = d.batches;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
              Text('${p.origin} · ${p.farmName}'),
              Text('¥${p.price}/${p.unit}'),
              if (p.coldChain) const Chip(label: Text('冷链配送 +12元 Mock')),
              const SizedBox(height: 8),
              Text(p.description),
              Row(
                children: [
                  TextButton(onPressed: () => context.push('/farm/${p.farmId}'), child: const Text('农户店铺')),
                  TextButton(onPressed: () => context.push('/product/$productId/reports'), child: const Text('质检报告')),
                ],
              ),
              FilledButton(
                onPressed: () async {
                  await ref.read(agriRepositoryProvider).addToCart(productId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入购物车')));
                  }
                },
                child: const Text('加入购物车'),
              ),
              const Divider(),
              const Text('溯源批次'),
              ...batches.map((b) {
                return Card(
                  child: ListTile(
                    title: Text('批次 ${b.batchNo}'),
                    subtitle: Text('溯源码: ${b.traceCode}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () => _showQr(context, b.traceCode),
                    ),
                    onTap: () => context.push('/trace/${b.traceCode}'),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  void _showQr(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('溯源码 $code'),
        content: QrImageView(data: code, size: 200),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }
}

final _detailProvider = FutureProvider.family(
  (ref, String id) => ref.read(agriRepositoryProvider).productDetail(id),
);
