part of '../../page/register_page.dart';

final class _RegisterErrorText extends StatelessWidget {
  const _RegisterErrorText({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return (error != null)
        ? ThemeTypography.bodyMedium(
            context,
            error!,
            color: context.colorScheme.error,
            weight: FontWeight.w800,
          )
        : const SizedBox.shrink();
  }
}
