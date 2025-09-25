import 'api_client.dart';

class JobService {
  final _api = ApiClient();

  Future<String> startByKey(String key, {String? mime}) async {
    final res = await _api.dio.post('/upload/by-key',
        data: {'key': key, if (mime != null) 'mime': mime});
    final data = res.data as Map<String, dynamic>;
    return data['jobId']?.toString() ?? '';
  }

  /// Expected backend response shape:
  /// { status: "queued|processing|done|error", receipt?: {...}, message?: string }
  Future<Map<String, dynamic>> getJob(String jobId) async {
    final res = await _api.dio.get('/job/$jobId');
    return (res.data as Map).map((k, v) => MapEntry(k.toString(), v));
  }
}
