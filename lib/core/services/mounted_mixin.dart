import 'package:flutter_bloc/flutter_bloc.dart';

mixin MountedCubit<State> on Cubit<State> {
  bool _mounted = true;

  @override
  void emit(State state) {
    if (!_mounted) return;
    try {
      super.emit(state);
    } catch (e) {
      if (e is StateError && e.message.contains('Cannot emit new states after calling close')) {
        // Silently ignore the error when trying to emit after close
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _mounted = false;
    return super.close();
  }
}