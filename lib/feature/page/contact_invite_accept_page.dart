import 'dart:async';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/app/services/connections_service.dart';
import 'package:flutter/material.dart';

class PageContactInviteAccept extends StatefulWidget {
  const PageContactInviteAccept({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<PageContactInviteAccept> createState() =>
      _PageContactInviteAcceptState();
}

class _PageContactInviteAcceptState extends State<PageContactInviteAccept> {
  late final ConnectionsService _connectionsService;

  bool _submitting = true;
  bool _success = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _connectionsService = ConnectionsService(apiClient: ApiClient());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_acceptInvite());
    });
  }

  Future<void> _acceptInvite() async {
    final token = widget.initialToken?.trim();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _success = false;
        _message = 'Davet bağlantısı geçersiz.';
      });
      return;
    }

    try {
      final message = await _connectionsService.acceptInviteByToken(token);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _success = true;
        _message = message ?? 'Davet başarıyla kabul edildi.';
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _success = false;
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    _submitting
                        ? Icons.hourglass_top_rounded
                        : _success
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                    size: 56,
                    color: _submitting
                        ? Theme.of(context).colorScheme.primary
                        : _success
                            ? context.theme.success
                            : context.theme.error,
                  ),
                  const SizedBox(height: 20),
                  ThemeTypography.bodyLarge(
                    context,
                    _submitting
                        ? 'Davet kabul ediliyor'
                        : _success
                            ? 'Davet kabul edildi'
                            : 'Davet kabul edilemedi',
                    textAlign: TextAlign.center,
                    color:
                        _success ? context.theme.success : context.theme.error,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 12),
                  ThemeTypography.bodyLarge(
                    context,
                    _submitting
                        ? "İsteğiniz backend API'ye gönderiliyor."
                        : (_message ?? ''),
                    textAlign: TextAlign.center,
                    color: _submitting
                        ? context.colorScheme.primary
                        : _success
                            ? context.theme.success
                            : context.colorScheme.error,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 24),
                  if (_submitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        _success ? '/connections' : '/login',
                        (route) => false,
                      ),
                      child: ThemeTypography.bodyLarge(
                        context,
                        _success ? 'Bağlantılara Git' : 'Giriş Yap',
                        color: _success
                            ? context.theme.success
                            : context.theme.brandPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
