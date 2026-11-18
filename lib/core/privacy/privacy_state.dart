import 'package:equatable/equatable.dart';

/// Estado que controla la visibilidad de los importes.
class PrivacyState extends Equatable {
  final bool hidden;

  const PrivacyState({this.hidden = false});

  PrivacyState copyWith({bool? hidden}) {
    return PrivacyState(hidden: hidden ?? this.hidden);
  }

  @override
  List<Object?> get props => [hidden];
}
