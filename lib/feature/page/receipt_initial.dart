import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_service.dart';
import 'package:flutter/material.dart';

part '../connection/receipt_initial.dart';
part '../view/receipt_initial.dart';

class PageReceiptInitial extends StatefulWidget {
  const PageReceiptInitial({super.key});

  @override
  State<PageReceiptInitial> createState() => _PageReceiptInitialState();
}

class _PageReceiptInitialState extends State<PageReceiptInitial>
    with _ConnectionReceiptInitial {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _ReceiptInitialView(),
    );
  }
}
