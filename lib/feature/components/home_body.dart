part of '../../page/home.dart';

final class BodyHome extends StatelessWidget {
  const BodyHome(
      {super.key, required this.controller, required this.futureSummary,required this.reload});

  final ScrollController controller;
  final Future<HomeSummary> futureSummary;
  final Future<void> reload;
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.height;
    return SafeArea(
        child: SingleChildScrollView(
            controller: controller,
            padding: ThemePadding.all24(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: ThemeSize.spacingL,
              children: [
                SizedBox(height: size * 0.075),
              ],
            )));
  }
}


// ignore: unused_element
final class _HomeStateSection extends StatelessWidget {
  const _HomeStateSection({required this.state, required this.onLogin});

  final ValueNotifier<HomePageState> state;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomePageState>(
      valueListenable: state,
      builder: (context, currentState, _) {
        return Column(
          children: [
            if (currentState.errorMessage.isNotEmpty)
            
            const SizedBox(height: ThemeSize.spacingL),

          ],
        );
      },
    );
  }
}


final class _HomeError extends StatelessWidget {
  final String? details;
  final Future<void> Function() onRetry;

  const _HomeError({
    super.key,
    this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Veriler alınırken bir hata oluştu.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
