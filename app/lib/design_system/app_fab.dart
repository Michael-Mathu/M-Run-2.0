import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

class AppFAB extends ConsumerWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  const AppFAB({
    super.key,
    required this.onPressed,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = ref.watch(trackingModelProvider).state == AppEngineState.recording;
    const base = AppTheme.brand;
    return Semantics(
      button: true,
      label: isRecording ? 'Stop run' : 'Start run',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: recording ? 1.0 : 0.4),
                blurRadius: recording ? 16 : 12,
                spreadRadius: recording ? 3 : 2,
              ),
            ],
          ),
          child: Icon(
            recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
