// lib/services/job_polling_service.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/model/status_type.dart';

class JobPollingService {
  Timer? _timer;
  bool _active = false;
  final CancelToken _cancelToken = CancelToken();

  /// Start polling every [intervalSec] secs until "done"/"failed" or [stop] called.
  Future<void> start({
    required String jobId,
    required void Function(Map<String, dynamic> job) onUpdate,
    required void Function(Object error) onError,
    int intervalSec = 10,
  }) async {
    if (_active) return;
    _active = true;

    Future<void> tick() async {
      if (!_active) return;
      try {
        final res = await ApiClient().dio.get<Map<String, dynamic>>(
              '/api/job/$jobId',
              cancelToken: _cancelToken,
            );
        final data = res.data!;
        final job = data['job'] as Map<String, dynamic>;
        onUpdate(job);

        final status = (job['status'] as String?) ?? '';
        if (status == StatusType.done.name ||
            status == StatusType.failed.name) {
          stop();
          return;
        }
      } on Exception catch (e) {
        onError(e);
        // Optional: backoff or stop on certain errors
      }
      if (_active) {
        _timer = Timer(Duration(seconds: intervalSec), tick);
      }
    }

    // fire immediately, then schedule
    await tick();
  }

  void stop() {
    _active = false;
    _timer?.cancel();
    if (!_cancelToken.isCancelled) _cancelToken.cancel('stopped');
  }
}
