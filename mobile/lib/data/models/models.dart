import 'package:flutter/foundation.dart';

@immutable
class AgriUser {
  const AgriUser({required this.id, required this.phone, required this.name});

  factory AgriUser.fromJson(Map<String, dynamic> json) => AgriUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String phone;
  final String name;
}

@immutable
class Category {
  const Category({required this.id, required this.name, this.coldChain = false});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        coldChain: (json['cold_chain'] as num?)?.toInt() == 1,
      );

  final String id;
  final String name;
  final bool coldChain;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.origin,
    this.farmId = '',
    this.farmName = '',
    this.categoryName = '',
    this.imageUrl = '',
    this.description = '',
    this.coldChain = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String? ?? '斤',
        origin: json['origin'] as String? ?? '',
        farmId: json['farm_id'] as String? ?? '',
        farmName: json['farm_name'] as String? ?? '',
        categoryName: json['category_name'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        description: json['description'] as String? ?? '',
        coldChain: (json['cold_chain'] as num?)?.toInt() == 1,
      );

  final String id;
  final String name;
  final double price;
  final String unit;
  final String origin;
  final String farmId;
  final String farmName;
  final String categoryName;
  final String imageUrl;
  final String description;
  final bool coldChain;
}

@immutable
class Batch {
  const Batch({
    required this.id,
    required this.batchNo,
    required this.harvestDate,
    required this.traceCode,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json['id'] as String,
        batchNo: json['batch_no'] as String,
        harvestDate: json['harvest_date'] as String,
        traceCode: json['trace_code'] as String,
      );

  final String id;
  final String batchNo;
  final String harvestDate;
  final String traceCode;
}

@immutable
class TraceNode {
  const TraceNode({
    required this.step,
    required this.title,
    required this.detail,
    required this.location,
    required this.occurredAt,
  });

  factory TraceNode.fromJson(Map<String, dynamic> json) => TraceNode(
        step: (json['step'] as num).toInt(),
        title: json['title'] as String,
        detail: json['detail'] as String? ?? '',
        location: json['location'] as String? ?? '',
        occurredAt: json['occurred_at'] as String,
      );

  final int step;
  final String title;
  final String detail;
  final String location;
  final String occurredAt;
}

@immutable
class AgriOrder {
  const AgriOrder({
    required this.id,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    this.subtotal = 0,
    this.coldChainFee = 0,
    this.depositAmount = 0,
    this.balanceAmount = 0,
    this.items = const [],
    this.createdAt = '',
  });

  factory AgriOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] ?? json['items_json'];
    List<dynamic> itemsList = [];
    if (itemsRaw is List) {
      itemsList = itemsRaw;
    }
    return AgriOrder(
      id: json['id'] as String,
      orderType: json['order_type'] as String? ?? 'normal',
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      coldChainFee: (json['cold_chain_fee'] as num?)?.toDouble() ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0,
      items: itemsList.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  final String id;
  final String orderType;
  final String status;
  final double totalAmount;
  final double subtotal;
  final double coldChainFee;
  final double depositAmount;
  final double balanceAmount;
  final List<Map<String, dynamic>> items;
  final String createdAt;
}
