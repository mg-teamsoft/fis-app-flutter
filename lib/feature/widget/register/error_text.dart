part of '../../page/register.dart';

final class _RegisterErrorText extends StatelessWidget {
  const _RegisterErrorText({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return (error != null)
        ? Text(
            error!,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: context.colorScheme.error),
          )
        : const SizedBox.shrink();
  }
}
