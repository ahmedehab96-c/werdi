import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:werdi/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:werdi/features/auth/presentation/widgets/auth_header.dart';
import 'package:werdi/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(repository: AppInjector.authGateway),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (previous, current) =>
            previous.didSubmitSuccessfully != current.didSubmitSuccessfully,
        listener: (context, state) {
          if (!state.didSubmitSuccessfully) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.resetLinkSent)),
          );
          context.pop();
        },
        child: AppScaffold(
          maxContentWidth: 480,
          appBar: AppBar(title: Text(context.l10n.forgotPasswordTitle)),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
              builder: (context, state) {
                final cubit = context.read<ForgotPasswordCubit>();
                final l10n = context.l10n;
                return Column(
                  children: [
                    AuthHeader(
                      title: l10n.forgotPasswordTitle,
                      subtitle: l10n.forgotPasswordSubtitle,
                    ),
                    AppVSpace.of(AppSpacing.xl),
                    AuthTextField(
                      label: l10n.emailLabel,
                      hint: 'example@mail.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      errorText: state.emailError,
                      onChanged: cubit.emailChanged,
                    ),
                    AppVSpace.of(AppSpacing.lg),
                    AppButton(
                      label: l10n.sendResetLink,
                      isLoading: state.isSubmitting,
                      onPressed: cubit.submit,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
