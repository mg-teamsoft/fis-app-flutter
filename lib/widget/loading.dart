import 'package:fis_app_flutter/page/error/error.dart';
import 'package:flutter/material.dart';

class WidgetLoading<T> extends StatelessWidget {
  const WidgetLoading(
      {super.key,
      required this.future,
      required this.error,
      required this.reload,
      required this.body});

  final Future<T> future;
  final PageError error;
  final Future<void> Function() reload;
  final Widget Function(T? summary) body;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return error(
              details: snapshot.error?.toString(),
              onRetry: reload,
            );
          }

          final summary = snapshot.data;
          if (summary == null) {
            return error(onRetry: reload);
          }
          return RefreshIndicator(onRefresh: reload, child: body(summary));
        });
  }
}
