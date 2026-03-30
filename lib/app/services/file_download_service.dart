import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileDownloadService {
  final Dio _dio;
  FileDownloadService([Dio? dio]) : _dio = dio ?? Dio();

  /// Download to the app's documents directory and return the absolute path.
  Future<String> downloadToAppDocs(String url,
      {required String fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      filePath,
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );

    return filePath;
  }

  /// Download to temporary directory and return the path (good for Open).
  Future<String> downloadToTemp(String url, {required String fileName}) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      filePath,
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );

    return filePath;
  }

  /// Open a local file with the platform viewer.
  Future<OpenResult> openLocal(String filePath) async {
    return OpenFilex.open(filePath);
  }
}
