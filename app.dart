import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/core/constants/route_constants.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';
import 'package:quran_sheikh_app/presentation/screens/dialogs/force_update_dialog.dart';
import 'presentation/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/version_provider.dart';

class QuranSheikhApp extends ConsumerWidget {
  const QuranSheikhApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for token expiry
    authExpiredNotifier.addListener(() {
      if (authExpiredNotifier.value) {
        authExpiredNotifier.value = false;
        ref.read(authProvider.notifier).forceLogout();
        AppRouter.router.go(RouteConstants.LOGIN);
      }
    });

    final versionState = ref.watch(versionProvider);

    // ✅ Trigger version check when auth changes
    ref.listen(authProvider, (prev, next) {
      if (next.user != null && next.minimumRequiredVersion != null) {
        ref
            .read(versionProvider.notifier)
            .checkVersion(next.minimumRequiredVersion!);
      }
    });

    // ✅ Show dialog when version state changes
    ref.listen(versionProvider, (prev, next) {
      if (next.updateRequired && next.requiredVersion != null) {
        // ✅ Use addPostFrameCallback for better timing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navContext = AppRouter.navigatorKey.currentContext;
          if (navContext != null && navContext.mounted) {
            showDialog(
              context: navContext,
              barrierDismissible: false,
              builder: (_) => ForceUpdateDialog(
                currentVersion: next.currentVersion ?? '1.0.0',
                requiredVersion: next.requiredVersion!,
                appStoreUrl: 'https://apps.apple.com/app/your-app-id',
                playStoreUrl:
                    'https://play.google.com/store/apps/details?id=com.alfrugan.sheiks',
                isDark: Theme.of(navContext).brightness == Brightness.dark,
              ),
            );
          }
        });
      }
    });

    return MaterialApp.router(
      title: 'Quran Sheikh App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // Arabic
        Locale('en', ''), // English
      ],
      locale: const Locale('ar', ''), // Default to Arabic
    );
  }
}
