import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_market/features/shared/presentation/trace_timeline.dart';
import 'package:agri_market/data/models/models.dart';

void main() {
  testWidgets('TraceTimeline renders steps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TraceTimeline(
          nodes: [
            TraceNode(step: 1, title: '种植', detail: 'd', location: '山东', occurredAt: '2025-01-01'),
            TraceNode(step: 2, title: '采摘', detail: 'd', location: '山东', occurredAt: '2025-01-02'),
          ],
          ),
        ),
      ),
    );
    expect(find.text('种植'), findsOneWidget);
    expect(find.text('采摘'), findsOneWidget);
  });
}
