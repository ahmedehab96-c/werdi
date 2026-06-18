import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/auth/presentation/cubit/register_cubit.dart';
import 'package:werdi/features/auth/presentation/cubit/register_state.dart';
import 'package:werdi/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:werdi/features/auth/presentation/widgets/social_login_section.dart';
import 'package:werdi/routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(repository: AppInjector.authGateway),
      child: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (previous, current) =>
            previous.didSubmitSuccessfully != current.didSubmitSuccessfully,
        listener: (context, state) {
          if (!state.didSubmitSuccessfully) return;
          context.goNamed(AppRoutes.home);
        },
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            final cubit = context.read<RegisterCubit>();
            final l10n = context.l10n;
            return SingleChildScrollView(
              child: Column(
                children: [
                  AuthTextField(
                    label: l10n.fullNameLabel,
                    textInputAction: TextInputAction.next,
                    errorText: state.nameError,
                    onChanged: cubit.nameChanged,
                  ),
                  AppVSpace.of(AppSpacing.md),
                  AuthTextField(
                    label: l10n.emailLabel,
                    hint: 'example@mail.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: state.emailError,
                    onChanged: cubit.emailChanged,
                  ),
                  AppVSpace.of(AppSpacing.md),
                  AuthTextField(
                    label: l10n.passwordLabel,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    errorText: state.passwordError,
                    onChanged: cubit.passwordChanged,
                  ),
                  AppVSpace.of(AppSpacing.md),
                  AuthTextField(
                    label: l10n.confirmPasswordLabel,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    errorText: state.confirmPasswordError,
                    onChanged: cubit.confirmPasswordChanged,
                  ),
                  AppVSpace.of(AppSpacing.md),
                  AppButton(
                    label: l10n.registerButton,
                    isLoading: state.isSubmitting,
                    onPressed: cubit.submit,
                  ),
                  const SocialLoginSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
