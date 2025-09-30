// lib/services/job_polling_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../services/api_client.dart';

class JobPollingService {
  Timer? _timer;
  bool _active = false;
  final CancelToken _cancelToken = CancelToken();

  /// Start polling every [intervalSec] secs until "done"/"failed" or [stop] called.
  void start({
    required String jobId,
    int intervalSec = 10,
    required void Function(Map<String, dynamic> job) onUpdate,
    required void Function(Object error) onError,
  }) {
    if (_active) return;
    _active = true;

    Future<void> tick() async {
      if (!_active) return;
      try {
        final res =
            await ApiClient().dio.get('/api/job/$jobId', cancelToken: _cancelToken);
        final data = res.data as Map<String, dynamic>;
        final job = data['job'] as Map<String, dynamic>;
        onUpdate(job);

        final status = (job['status'] as String?) ?? '';
        if (status == 'done' || status == 'failed') {
          stop();
          return;
        }
      } catch (e) {
        onError(e);
        // Optional: backoff or stop on certain errors
      }
      if (_active) {
        _timer = Timer(Duration(seconds: intervalSec), tick);
      }
    }

    // fire immediately, then schedule
    tick();
  }

  void stop() {
    _active = false;
    _timer?.cancel();
    if (!_cancelToken.isCancelled) _cancelToken.cancel('stopped');
  }
}
