import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/agri_repository.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(_reportsProvider(productId));
    return Scaffold(
      appBar: AppBar(title: const Text('质检报告')),
      body: reports.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final r = items[i];
            return ListTile(
              title: Text(r['title'] as String? ?? ''),
              subtitle: Text(r['pdf_url'] as String? ?? ''),
              trailing: const Icon(Icons.picture_as_pdf),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _reportsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.read(agriRepositoryProvider).reports(id),
);
