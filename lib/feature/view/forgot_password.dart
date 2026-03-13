import 'package:flutter/material.dart';

@immutable
final class ForgotPasswordPageState {
  const ForgotPasswordPageState(
      {this.errorMessage = '', this.isLoading = false});

  final String errorMessage;
  final bool isLoading;

  ForgotPasswordPageState copyWith({String? errorMessage, bool? isLoading}) {
    return ForgotPasswordPageState(
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return false;
    return other is ForgotPasswordPageState &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => errorMessage.hashCode ^ isLoading.hashCode;
}
