import 'package:flutter/material.dart';

@immutable
final class HomePageState {
  const HomePageState({this.errorMessage = '', this.isLoading = false});

  final String errorMessage;
  final bool isLoading;

  HomePageState copyWith({String? errorMessage, bool? isLoading}) {
    return HomePageState(
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return false;
    return other is HomePageState &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => errorMessage.hashCode ^ isLoading.hashCode;
}
