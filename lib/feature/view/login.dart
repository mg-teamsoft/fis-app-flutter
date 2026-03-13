import 'package:flutter/material.dart';

@immutable
final class LoginPageState {
  const LoginPageState({this.errorMessage = '', this.isLoading = false});

  final String errorMessage;
  final bool isLoading;

  LoginPageState copyWith({String? errorMessage, bool? isLoading}) {
    return LoginPageState(
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return false;
    return other is LoginPageState &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => errorMessage.hashCode ^ isLoading.hashCode;
}
