import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _q = TextEditingController();
  Map<String, dynamic>? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _q, decoration: const InputDecoration(hintText: '商品/产地/农户'))),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final r = await ref.read(agriRepositoryProvider).search(_q.text.trim());
                    setState(() => _result = r);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _result == null
                ? const SizedBox.shrink()
                : ListView(
                    children: [
                      ...((_result!['items'] as List?) ?? []).map((p) {
                        final m = Map<String, dynamic>.from(p as Map);
                        return ListTile(
                          title: Text(m['name'] as String),
                          onTap: () => context.push('/product/${m['id']}'),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
