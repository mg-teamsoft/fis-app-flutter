part of '../page/register.dart';

class _RegisterView extends StatelessWidget {
  const _RegisterView({
    required this.formKey,
    required this.scrollController,
    required this.validator,
    required this.userCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.plansFuture,
    required this.selectedPlanKey,
    required this.error,
    required this.loading,
    required this.onRegister,
    required this.retryPlans,
  });

  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final CoreEnterApp validator;
  final TextEditingController userCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final Future<List<PlanOption>> plansFuture;
  final String? selectedPlanKey;
  final String? error;
  final bool loading;
  final VoidCallback? onRegister;
  final VoidCallback retryPlans;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const ThemePadding.all16(),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: ThemeSize.spacingXXXl),
              const _RegisterLogo(),
              const SizedBox(height: ThemeSize.spacingS),
              _RegisterUsernameTextField(
                controller: userCtrl,
                reqValidator: validator.req,
              ),
              const SizedBox(height: ThemeSize.spacingS),
              _RegisterMailTextField(
                controller: emailCtrl,
                mailValidator: validator.email,
              ),
              const SizedBox(height: ThemeSize.spacingS),
              _RegisterPasswordTextField(
                controller: passCtrl,
                passValidator: validator.validatePassword,
                onPressed: onRegister,
                obscure: obscure,
              ),
              const SizedBox(height: ThemeSize.spacingXl),
              _RegisterPlanArea(
                initialSelectedPlanKey: selectedPlanKey,
                plansFuture: plansFuture,
                retryPlans: retryPlans,
              ),
              const SizedBox(height: ThemeSize.spacingXl),
              _RegisterErrorText(
                error: error,
              ),
              const SizedBox(height: ThemeSize.spacingXs),
              _RegisterButton(
                loading: loading,
                onPressed: onRegister,
              ),
              const SizedBox(height: ThemeSize.spacingS),
              _RegisterBackButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
              ),
              const SizedBox(height: ThemeSize.spacingXXXl),
            ],
          ),
        ),
      ),
    );
  }
}
