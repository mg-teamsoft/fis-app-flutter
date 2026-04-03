import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum ReceiptAction { capture, pick }

class PermissionService {
  /// Requests just-in-time permissions for the action.
  /// Returns true if permission(s) are granted or limited (iOS Photos Limited).
  static Future<bool> ensureFor(
    ReceiptAction action, {
    BuildContext? context,
  }) async {
    if (action == ReceiptAction.capture) {
      return _ensureCamera(context: context);
    } else {
      return _ensurePhotos(context: context);
    }
  }

  static Future<bool> _ensureCamera({BuildContext? context}) async {
    final current = await Permission.camera.status;
    if (current.isGranted) return true;

    if (current.isPermanentlyDenied || current.isRestricted) {
      final ctx = context;
      if (ctx == null || !ctx.mounted) {
        await openAppSettings();
        return false;
      }
      await _showGoToSettingsDialog(
        ctx,
        title: 'Kamera izni gerekli',
        message:
            'Kamera ile fiş fotoğrafı çekebilmek için ayarlardan kamera izni vermelisiniz.',
      );
      return false;
    }

    final requested = await Permission.camera.request();
    debugPrint('Camera permission result: $requested');

    if (requested.isGranted) return true;

    // iOS: if denied permanently, guide to settings
    if (requested.isPermanentlyDenied || requested.isRestricted) {
      final ctx = context;
      if (ctx == null || !ctx.mounted) {
        await openAppSettings();
        return false;
      }
      await _showGoToSettingsDialog(
        ctx,
        title: 'Kamera izni gerekli',
        message:
            'Kamera ile fiş fotoğrafı çekebilmek için ayarlardan kamera izni vermelisiniz.',
      );
      return false;
    }

    // denied for now
    return false;
  }

  /// Photos/Gallery:
  /// - iOS: Permission.photos (granted | limited)
  /// - Android 13+: Permission.photos (maps to READ_MEDIA_IMAGES)
  /// - Android <=12: Permission.storage
  static Future<bool> _ensurePhotos({BuildContext? context}) async {
    if (Platform.isIOS) {
      final st = await Permission.photos.status;
      if (st.isGranted || st.isLimited) return true;

      final req = await Permission.photos.request();
      if (req.isGranted || req.isLimited) return true;

      if (req.isPermanentlyDenied || req.isRestricted) {
        final ctx = context;
        if (ctx == null || !ctx.mounted) {
          await openAppSettings();
          return false;
        }
        await _showGoToSettingsDialog(
          ctx,
          title: 'Fotoğraflar izni gerekli',
          message:
              'Galeriden fiş seçebilmek için ayarlardan fotoğraflar izni vermelisiniz.',
        );
        return false;
      }
      return false;
    } else {
      // ANDROID
      // Try the modern photos permission first (Android 13+).
      var st = await Permission
          .photos.status; // on <=12 this usually returns denied/unsupported
      if (st.isGranted) return true;

      var req = await Permission.photos.request();
      if (req.isGranted) return true;

      // Fallback to legacy storage on older Androids
      st = await Permission.storage.status;
      if (st.isGranted) return true;

      req = await Permission.storage.request();
      if (req.isGranted) return true;

      if (req.isPermanentlyDenied || req.isRestricted) {
        final ctx = context;
        if (ctx == null || !ctx.mounted) {
          await openAppSettings();
          return false;
        }
        await _showGoToSettingsDialog(
          ctx,
          title: 'Depolama izni gerekli',
          message:
              'Galeriden fiş seçebilmek için ayarlardan depolama izni vermelisiniz.',
        );
        return false;
      }
      return false;
    }
  }

  static Future<void> _showGoToSettingsDialog(
    BuildContext? context, {
    required String title,
    required String message,
  }) async {
    if (context == null) {
      // no UI context: best effort open settings
      await openAppSettings();
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }
}
