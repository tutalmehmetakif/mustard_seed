import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../event/auth_event.dart';
import '../state/auth_state.dart';

/// Google/Apple/Email ile giriş, email ile kayıt ve "hesapsız devam et"
/// akışlarını yönetir.
///
/// [AuthRepository] üzerinden gelen `authStateChanges` stream'ine abone
/// olur — OAuth akışı tarayıcı/deep link üzerinden asenkron tamamlandığı
/// için giriş sonucu doğrudan `signInWithGoogle()` çağrısından değil,
/// bu stream'den (AuthUserChanged event'i ile) gelir. Email ile giriş/kayıt
/// ise senkron tamamlanır ama tutarlılık için aynı stream üzerinden akar.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthGuestContinueRequested>(_onGuestContinueRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthStreamErrorReceived>(_onStreamErrorReceived);

    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
      onError: (Object error, StackTrace _) {
        final message = error is AuthFailure
            ? error.message
            : 'Bir hata oluştu. Lütfen tekrar deneyin.';
        add(AuthStreamErrorReceived(message));
      },
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _authSubscription;

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      await _authRepository.signInWithGoogle();
      // Başarılı giriş, authStateChanges -> AuthUserChanged üzerinden gelecek.
    } on AuthFailure catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      await _authRepository.signInWithApple();
    } on AuthFailure catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onEmailSignUpRequested(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final requiresConfirmation = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
      );
      if (requiresConfirmation) {
        emit(state.copyWith(
          status: AuthStatus.emailConfirmationRequired,
          pendingEmail: event.email,
        ));
      }
      // requiresConfirmation false ise session zaten oluştu,
      // authStateChanges -> AuthUserChanged authenticated'a çevirecek.
    } on AuthFailure catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onEmailSignInRequested(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
    } on AuthFailure catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onGuestContinueRequested(
    AuthGuestContinueRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      await _authRepository.continueAsGuest();
      emit(state.copyWith(status: AuthStatus.guest));
    } on AuthFailure catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: event.user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      user: event.user,
    ));
  }

  void _onStreamErrorReceived(
    AuthStreamErrorReceived event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.failure,
      errorMessage: event.message,
    ));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}