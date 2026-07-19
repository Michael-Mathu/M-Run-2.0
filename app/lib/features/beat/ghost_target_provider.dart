import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/learn/data/beat_legends.dart';

/// The ghost the user is currently racing, set when launching a run from
/// "Beat the Legends". Null for a normal run.
class GhostTarget extends Notifier<GhostPace?> {
  @override
  GhostPace? build() => null;

  void set(GhostPace? ghost) => state = ghost;
}

final ghostTargetProvider =
    NotifierProvider<GhostTarget, GhostPace?>(GhostTarget.new);
