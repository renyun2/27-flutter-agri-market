import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TraceQueryPage extends StatefulWidget {
  const TraceQueryPage({super.key});

  @override
  State<TraceQueryPage> createState() => _TraceQueryPageState();
}

class _TraceQueryPageState extends State<TraceQueryPage> {
  final _code = TextEditingController(text: 'AGRI-001-1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('溯源查询')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: '输入溯源码'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/trace/${_code.text.trim()}'),
              child: const Text('查询'),
            ),
          ],
        ),
      ),
    );
  }
}
