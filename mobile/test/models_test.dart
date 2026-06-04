import 'package:flutter_test/flutter_test.dart';
import 'package:agri_market/data/models/models.dart';

void main() {
  test('Product fromJson', () {
    final p = Product.fromJson({
      'id': '1',
      'name': '苹果',
      'price': 12.5,
      'unit': '斤',
      'origin': '山东',
    });
    expect(p.name, '苹果');
    expect(p.price, 12.5);
  });

  test('TraceNode fromJson', () {
    final n = TraceNode.fromJson({
      'step': 1,
      'title': '种植',
      'occurred_at': '2025-01-01',
    });
    expect(n.title, '种植');
  });
}
