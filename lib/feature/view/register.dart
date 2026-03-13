import 'package:flutter/material.dart';

@immutable
final class RegisterPageState {
  const RegisterPageState({this.errorMessage = '', this.isLoading = false});

  final String errorMessage;
  final bool isLoading;

  RegisterPageState copyWith({String? errorMessage, bool? isLoading}) {
    return RegisterPageState(
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return false;
    return other is RegisterPageState &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => errorMessage.hashCode ^ isLoading.hashCode;
}
