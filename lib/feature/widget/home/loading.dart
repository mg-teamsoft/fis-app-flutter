part of '../../page/home.dart';

final class _LoadingHome extends StatelessWidget {
  const _LoadingHome(
      {required this.summary, required this.reload, required this.size});

  final Future<ModelHome> summary;
  final Future<void> Function() reload;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: summary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _HomeError(
            details: snapshot.error?.toString(),
            onRetry: reload,
          );
        }

        final summary = snapshot.data;
        if (summary == null) {
          return _HomeError(onRetry: reload);
        }

        return RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const ThemePadding.all20(),
            children: [_HomeView(size: size, model: snapshot.data!)],
          ),
        );
      },
    );
  }
}
