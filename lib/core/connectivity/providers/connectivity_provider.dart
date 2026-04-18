import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  final controller = StreamController<bool>();

  Future<void> emitCurrent() async {
    final result = await connectivity.checkConnectivity();
    controller.add(_hasConnection(result));
  }

  emitCurrent();

  final sub = connectivity.onConnectivityChanged.listen((result) {
    controller.add(_hasConnection(result));
  });

  ref.onDispose(() async {
    await sub.cancel();
    await controller.close();
  });

  return controller.stream.distinct();
});

bool _hasConnection(dynamic result) {
  if (result is List<ConnectivityResult>) {
    return result.any((item) => item != ConnectivityResult.none);
  }

  if (result is ConnectivityResult) {
    return result != ConnectivityResult.none;
  }

  return true;
}
