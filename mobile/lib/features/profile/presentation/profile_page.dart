import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          ListTile(title: Text(user?.name ?? '未登录'), subtitle: Text(user?.phone ?? '')),
          ListTile(title: const Text('我的订单'), onTap: () => context.push('/orders')),
          ListTile(title: const Text('订阅箱'), onTap: () => context.push('/subscriptions')),
          ListTile(title: const Text('优惠券'), onTap: () => context.push('/coupons')),
          ListTile(title: const Text('设置'), onTap: () => context.push('/settings')),
          ListTile(
            title: const Text('退出登录'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
