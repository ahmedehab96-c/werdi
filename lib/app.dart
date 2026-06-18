import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/app/state/locale_cubit.dart';
import 'package:werdi/app/state/theme_cubit.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/theme/app_theme.dart';
import 'package:werdi/l10n/app_localizations.dart';
import 'package:werdi/routes/app_router.dart';

class WerdiApp extends StatelessWidget {
  const WerdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()..load(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit()..load(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.select(
            (ThemeCubit cubit) => cubit.state,
          );
          final locale = context.select(
            (LocaleCubit cubit) => cubit.state,
          );
          return ScreenUtilInit(
            designSize: AppConstants.designSize,
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: AppConstants.appName,
                themeMode: themeMode,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                locale: locale,
                supportedLocales: AppConstants.supportedLocales,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
