import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/auth/presentation/cubit/login_cubit.dart';
import 'package:werdi/features/auth/presentation/cubit/login_state.dart';
import 'package:werdi/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:werdi/features/auth/presentation/widgets/social_login_section.dart';
import 'package:werdi/routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(repository: AppInjector.authGateway),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            previous.didSubmitSuccessfully != current.didSubmitSuccessfully,
        listener: (context, state) {
          if (!state.didSubmitSuccessfully) return;
          context.goNamed(AppRoutes.home);
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            final cubit = context.read<LoginCubit>();
            final l10n = context.l10n;
            return SingleChildScrollView(
              child: Column(
                children: [
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
                    textInputAction: TextInputAction.done,
                    errorText: state.passwordError,
                    onChanged: cubit.passwordChanged,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.forgotPassword),
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                  AppButton(
                    label: l10n.loginButton,
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
