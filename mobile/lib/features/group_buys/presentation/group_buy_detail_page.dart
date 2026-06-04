import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/agri_repository.dart';

class GroupBuyDetailPage extends ConsumerStatefulWidget {
  const GroupBuyDetailPage({super.key, required this.groupBuyId});
  final String groupBuyId;

  @override
  ConsumerState<GroupBuyDetailPage> createState() => _GroupBuyDetailPageState();
}

class _GroupBuyDetailPageState extends ConsumerState<GroupBuyDetailPage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String? _expireStarted;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(String expireAt) {
    _timer?.cancel();
    void tick() {
      final end = DateTime.tryParse(expireAt.replaceFirst(' ', 'T')) ?? DateTime.now();
      setState(() {
        _remaining = end.difference(DateTime.now());
        if (_remaining.isNegative) _remaining = Duration.zero;
      });
    }
    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_gbProvider(widget.groupBuyId));
    return Scaffold(
      appBar: AppBar(title: const Text('拼团详情')),
      body: data.when(
        data: (json) {
          final g = Map<String, dynamic>.from(json['group_buy'] as Map);
          final members = json['members'] as List;
          final exp = g['expire_at'] as String;
          if (_expireStarted != exp) {
            _expireStarted = exp;
            _startTimer(exp);
          }
          final h = _remaining.inHours;
          final m = _remaining.inMinutes % 60;
          final s = _remaining.inSeconds % 60;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g['product_name'] as String? ?? '', style: Theme.of(context).textTheme.titleLarge),
                Text('拼团价 ¥${g['group_price']}'),
                Text('倒计时: ${h}h ${m}m ${s}s'),
                Text('进度 ${g['member_count']}/${g['target_count']} · ${g['status']}'),
                const Divider(),
                const Text('成员'),
                ...members.map((m) {
                  final map = Map<String, dynamic>.from(m as Map);
                  return ListTile(title: Text(map['user_name'] as String? ?? map['user_id'] as String));
                }),
                if (g['status'] == 'open')
                  FilledButton(
                    onPressed: () async {
                      await ref.read(agriRepositoryProvider).joinGroupBuy(widget.groupBuyId);
                      ref.invalidate(_gbProvider(widget.groupBuyId));
                    },
                    child: const Text('参团'),
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

final _gbProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, id) => ref.read(agriRepositoryProvider).groupBuy(id),
);
