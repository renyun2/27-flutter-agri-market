import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

class TraceTimeline extends StatelessWidget {
  const TraceTimeline({super.key, required this.nodes});

  final List<TraceNode> nodes;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: nodes.isEmpty ? 0 : nodes.length - 1,
      controlsBuilder: (_, __) => const SizedBox.shrink(),
      steps: nodes
          .map(
            (n) => Step(
              title: Text(n.title),
              subtitle: Text('${n.location} · ${n.occurredAt}'),
              content: Align(
                alignment: Alignment.centerLeft,
                child: Text(n.detail),
              ),
              isActive: true,
              state: StepState.complete,
            ),
          )
          .toList(),
    );
  }
}
