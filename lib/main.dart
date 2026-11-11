import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lodbod_app/core/config/firebase_options.dart';
import 'package:lodbod_app/l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_settings.dart';
import 'core/config/app_router.dart';
import 'core/utils/logger.dart';
import 'core/di/injection_container.dart' as di;
import 'core/widgets/brand_splash.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Hive.initFlutter();
    await appSettings.load();
    if (mounted) setState(() {});
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      AppLogger.info('Firebase initialized with offline support');
    } catch (e, stackTrace) {
      AppLogger.error('Firebase initialization failed', e, stackTrace);
    }

    await di.init();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appSettings.themeMode,
        home: BrandSplash(statusText: 'Preparing your app...'),
      );
    }
    return const LodBodApp();
  }
}

class LodBodApp extends StatelessWidget {
  const LodBodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: AnimatedBuilder(
        animation: appSettings,
        builder: (context, _) => MaterialApp.router(
          title: 'Lod Bod',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appSettings.themeMode,
          locale: appSettings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en'), Locale('ne'), Locale('hi')],
          routerConfig: AppRouter.router,
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: isDark
                    ? Brightness.dark
                    : Brightness.light,
                systemStatusBarContrastEnforced: false,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
