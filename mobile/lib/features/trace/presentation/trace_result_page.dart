import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/agri_repository.dart';
import '../../shared/presentation/trace_timeline.dart';

class TraceResultPage extends ConsumerWidget {
  const TraceResultPage({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_traceProvider(code));
    return Scaffold(
      appBar: AppBar(title: const Text('溯源结果')),
      body: data.when(
        data: (json) {
          final batch = Map<String, dynamic>.from(json['batch'] as Map);
          final nodes = (json['nodes'] as List)
              .map((e) => TraceNode.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          final traceCode = json['trace_code'] as String;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(batch['product_name'] as String? ?? '', style: Theme.of(context).textTheme.titleLarge),
              Text('产地: ${batch['origin']} · ${batch['farm_name']}'),
              Center(child: QrImageView(data: traceCode, size: 120)),
              const Text('溯源链路'),
              TraceTimeline(nodes: nodes),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('溯源码无效: $e')),
      ),
    );
  }
}

final _traceProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, code) => ref.read(agriRepositoryProvider).trace(code),
);
