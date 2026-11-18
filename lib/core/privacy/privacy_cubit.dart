import 'package:flutter_bloc/flutter_bloc.dart';
import 'privacy_state.dart';

/// Cubit encargado de controlar la privacidad de los importes.
class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  /// Alterna entre mostrar y ocultar los importes.
  void toggle() {
    emit(state.copyWith(hidden: !state.hidden));
  }

  /// Oculta todos los importes.
  void hide() {
    emit(state.copyWith(hidden: true));
  }

  /// Muestra nuevamente los importes.
  void show() {
    emit(state.copyWith(hidden: false));
  }
}
