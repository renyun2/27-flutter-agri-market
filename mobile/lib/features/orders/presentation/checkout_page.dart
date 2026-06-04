import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _coupon = TextEditingController();
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('结算')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _coupon, decoration: const InputDecoration(labelText: '优惠券码（可选）')),
            const Text('冷链商品将加收 12 元运费 Mock'),
            const Spacer(),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        final order = await ref
                            .read(agriRepositoryProvider)
                            .checkout(couponCode: _coupon.text.trim().isEmpty ? null : _coupon.text.trim());
                        await ref.read(agriRepositoryProvider).payOrder(order.id);
                        if (mounted) context.go('/orders');
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: Text(_loading ? '提交中...' : '提交并支付 Mock'),
            ),
          ],
        ),
      ),
    );
  }
}
