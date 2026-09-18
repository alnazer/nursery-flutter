import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api/api_client.dart';
import '../core/api/api_failure.dart';
import '../core/api/auth_api.dart';
import '../core/api/auth_holder.dart';
import '../core/api/parent_api.dart';
import '../core/api/staff_api.dart';
import '../core/native/native_bridge.dart';
import '../core/storage/session_store.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/cubit/biometric_cubit.dart';
import '../features/auth/cubit/login_cubit.dart';
import '../features/auth/view/biometric_enable_page.dart';
import '../features/auth/view/blocker_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/home/home_page.dart';
import '../features/session/session_cubit.dart';
import '../l10n/app_localizations.dart';
import 'app_config.dart';

/// جذر التطبيق: يبني الاعتماديات مرة واحدة ويوزّعها على الـ Cubits.
class NurseryApp extends StatefulWidget {
  const NurseryApp({super.key, required this.flavor});

  final AppFlavor flavor;

  @override
  State<NurseryApp> createState() => _NurseryAppState();
}

class _NurseryAppState extends State<NurseryApp> {
  late final AppConfig _config;
  late final AuthHolder _holder;
  late final NativeBridge _native;
  late final SessionStore _store;
  late final ApiClient _client;
  late final AuthApi _api;
  late final ParentApi _parentApi;
  late final StaffApi _staffApi;
  late final SessionCubit _session;

  @override
  void initState() {
    super.initState();
    _config = AppConfig.fromEnvironment(widget.flavor);
    _holder = AuthHolder();
    _native = const NativeBridge();
    _store = SessionStore(_native);
    _client = ApiClient(
      config: _config,
      tokenProvider: () => _holder.token,
      localeProvider: () => _holder.locale,
      onUnauthenticated: (ApiFailure _) => _session.expired(),
    );
    _api = AuthApi(_client);
    _parentApi = ParentApi(_client);
    _staffApi = StaffApi(_client);
    _session = SessionCubit(
      config: _config,
      api: _api,
      client: _client,
      store: _store,
      native: _native,
      holder: _holder,
    );
    _session.bootstrap();
  }

  @override
  void dispose() {
    _session.close();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppConfig>.value(value: _config),
        RepositoryProvider<AuthApi>.value(value: _api),
        RepositoryProvider<NativeBridge>.value(value: _native),
        RepositoryProvider<SessionStore>.value(value: _store),
        RepositoryProvider<ParentApi>.value(value: _parentApi),
        RepositoryProvider<StaffApi>.value(value: _staffApi),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _session),
          BlocProvider<LoginCubit>(
            create: (BuildContext context) => LoginCubit(api: _api, session: _session),
          ),
          BlocProvider<BiometricCubit>(
            create: (BuildContext context) => BiometricCubit(api: _api, session: _session, native: _native),
          ),
        ],
        child: BlocBuilder<SessionCubit, SessionState>(
          buildWhen: (SessionState previous, SessionState current) => previous.locale != current.locale,
          builder: (BuildContext context, SessionState state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (BuildContext context) =>
                  _config.isStaff ? AppL10n.of(context).appNameStaff : AppL10n.of(context).appNameParent,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.system,
              locale: Locale(state.locale),
              localizationsDelegates: AppL10n.localizationsDelegates,
              supportedLocales: AppL10n.supportedLocales,
              home: const RootView(),
            );
          },
        ),
      ),
    );
  }
}

/// يختار الشاشة حسب حالة الجلسة، ويعرض الرسائل العابرة.
class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listenWhen: (SessionState previous, SessionState current) => current.notice != null,
      listener: (BuildContext context, SessionState state) {
        final AppL10n l10n = AppL10n.of(context);
        final SessionNotice? notice = state.notice;
        String text = '';
        switch (notice) {
          case SessionNotice.sessionExpired:
            text = l10n.sessionExpiredBody;
            break;
          case SessionNotice.staffReplaced:
            text = l10n.staffReplacedDevices;
            break;
          case SessionNotice.biometricRevoked:
            text = l10n.biometricRevoked;
            break;
          case SessionNotice.signedOut:
          case null:
            text = '';
            break;
        }
        if (text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        }
        context.read<SessionCubit>().consumeNotice();
      },
      builder: (BuildContext context, SessionState state) {
        switch (state.status) {
          case SessionStatus.loading:
            return const _SplashView();
          case SessionStatus.blocked:
            return BlockerPage(
              failure: state.blocker ?? const ApiFailure(code: ApiCode.serverError, message: ''),
            );
          case SessionStatus.signedOut:
            return const LoginPage();
          case SessionStatus.signedIn:
            return state.promptBiometric ? const BiometricEnablePage() : const HomeShell();
        }
      },
    );
  }
}

/// شاشة الإقلاع: مؤشّر تقدّم فقط — بلا مربّع شعار، لأن شعار الحضانة
/// لم يصل بعد في هذه اللحظة فيظهر مربّعاً فارغاً.
class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}
