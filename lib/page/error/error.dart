import 'package:flutter/material.dart';

typedef PageError = Widget Function(
    {String? details, required Future<void> Function() onRetry});
