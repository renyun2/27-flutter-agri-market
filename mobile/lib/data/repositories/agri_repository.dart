import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/models.dart';

final agriRepositoryProvider = Provider<AgriRepository>((ref) {
  return AgriRepository(ref.watch(dioProvider));
});

class AgriRepository {
  AgriRepository(this._dio);
  final Dio _dio;

  Future<({String token, AgriUser user})> login(String phone, String password) async {
    final res = await _dio.post('/api/auth/login', data: {'phone': phone, 'password': password});
    return (
      token: res.data['token'] as String,
      user: AgriUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map)),
    );
  }

  Future<AgriUser> me() async {
    final res = await _dio.get('/api/auth/me');
    return AgriUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map));
  }

  Future<void> logout() async => _dio.post('/api/auth/logout');

  Future<List<Category>> categories() async {
    final res = await _dio.get('/api/categories');
    return (res.data['items'] as List)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Product>> products({String? farmId, String? origin, String? categoryId}) async {
    final res = await _dio.get('/api/products', queryParameters: {
      if (farmId != null) 'farmId': farmId,
      if (origin != null) 'origin': origin,
      if (categoryId != null) 'categoryId': categoryId,
    });
    return (res.data['items'] as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<({Product product, List<Batch> batches})> productDetail(String id) async {
    final res = await _dio.get('/api/products/$id');
    return (
      product: Product.fromJson(Map<String, dynamic>.from(res.data['product'] as Map)),
      batches: (res.data['batches'] as List)
          .map((e) => Batch.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Future<Map<String, dynamic>> trace(String code) async {
    final res = await _dio.get('/api/trace/$code');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> farm(String id) async {
    final res = await _dio.get('/api/farms/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> presales() async {
    final res = await _dio.get('/api/presales');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> presale(String id) async {
    final res = await _dio.get('/api/presales/$id');
    return Map<String, dynamic>.from(res.data['presale'] as Map);
  }

  Future<AgriOrder> presaleDeposit(String presaleId) async {
    final res = await _dio.post('/api/presales/$presaleId/deposit');
    return AgriOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<List<Map<String, dynamic>>> groupBuys() async {
    final res = await _dio.get('/api/group-buys');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> groupBuy(String id) async {
    final res = await _dio.get('/api/group-buys/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createGroupBuy(String productId) async {
    final res = await _dio.post('/api/group-buys', data: {'productId': productId, 'action': 'create'});
    return Map<String, dynamic>.from(res.data['group_buy'] as Map);
  }

  Future<Map<String, dynamic>> joinGroupBuy(String groupBuyId) async {
    final res = await _dio.post('/api/group-buys', data: {'action': 'join', 'groupBuyId': groupBuyId});
    return Map<String, dynamic>.from(res.data['group_buy'] as Map);
  }

  Future<Map<String, dynamic>> cart() async {
    final res = await _dio.get('/api/cart');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> addToCart(String productId, {String? batchId, int qty = 1}) async {
    await _dio.post('/api/cart', data: {
      'productId': productId,
      if (batchId != null) 'batchId': batchId,
      'qty': qty,
    });
  }

  Future<AgriOrder> checkout({String? couponCode}) async {
    final res = await _dio.post('/api/orders', data: {if (couponCode != null) 'couponCode': couponCode});
    return AgriOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<List<AgriOrder>> orders() async {
    final res = await _dio.get('/api/orders');
    return (res.data['items'] as List)
        .map((e) => AgriOrder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<({AgriOrder order, List<AgriOrder> children})> orderDetail(String id) async {
    final res = await _dio.get('/api/orders/$id');
    return (
      order: AgriOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map)),
      children: (res.data['children'] as List? ?? [])
          .map((e) => AgriOrder.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Future<AgriOrder> payOrder(String id) async {
    final res = await _dio.post('/api/orders/$id/pay');
    return AgriOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<AgriOrder> payBalance(String id) async {
    final res = await _dio.post('/api/orders/$id/pay-balance');
    return AgriOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<List<Map<String, dynamic>>> subscriptions() async {
    final res = await _dio.get('/api/subscriptions');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/subscriptions', data: body);
    return Map<String, dynamic>.from(res.data['subscription'] as Map);
  }

  Future<List<Map<String, dynamic>>> reports(String productId) async {
    final res = await _dio.get('/api/products/$productId/reports');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> search(String q) async {
    final res = await _dio.get('/api/search', queryParameters: {'q': q});
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> coupons() async {
    final res = await _dio.get('/api/coupons');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> claimCoupon(String code) async {
    await _dio.post('/api/coupons/claim', data: {'code': code});
  }
}
