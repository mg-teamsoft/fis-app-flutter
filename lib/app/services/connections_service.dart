import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';

class SupervisorContactDto {
  SupervisorContactDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.permissions,
  });

  final String id;
  final String name;
  final String email;
  final String status;
  final List<ContactPermission> permissions;
}

class ConnectionsService {
  ConnectionsService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<SupervisorContactDto>> fetchSupervisors() async {
    try {
      final response =
          await _api.dio.get<Map<String, dynamic>>('/api/contacts/supervisors');
      if (response.statusCode != 200) {
        throw Exception('Bağlantılar alınamadı');
      }

      final items = _extractContactList(response.data);
      return items.map(_mapSupervisorContact).toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Bağlantılar alınamadı');
    }
  }

  Future<void> inviteSupervisor({
    required String email,
    required List<ContactPermission> permissions,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    if (normalizedEmail.isEmpty) {
      throw Exception('Geçerli bir e-posta adresi girin');
    }

    if (permissions.isEmpty) {
      throw Exception('En az bir yetki seçin');
    }

    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/api/contacts/invites',
        data: {
          'inviteeEmail': normalizedEmail,
          'permissions':
              permissions.map((permission) => permission.apiValue).toList(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Davet gönderilemedi');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Davet gönderilemedi');
    }
  }

  List<Map<String, dynamic>> _extractContactList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      const candidateKeys = [
        'data',
        'contacts',
        'supervisors',
        'items',
        'results',
      ];

      for (final key in candidateKeys) {
        final value = data[key];
        if (value is List) {
          return value
              .whereType<Map<String, dynamic>>()
              .map(Map<String, dynamic>.from)
              .toList();
        }
      }
    }

    return const [];
  }

  SupervisorContactDto _mapSupervisorContact(Map<String, dynamic> json) {
    final supervisor = json['supervisor'] is Map
        ? Map<String, dynamic>.from(json['supervisor'] as Map)
        : const <String, dynamic>{};
    final firstName = supervisor['firstName']?.toString().trim();
    final lastName = supervisor['lastName']?.toString().trim();
    final fullName = [firstName, lastName]
        .where((part) => part != null && part.isNotEmpty)
        .cast<String>()
        .join(' ');
    final email = _pickFirstNonEmpty([
      supervisor['email']?.toString(),
      json['email']?.toString(),
    ]);

    return SupervisorContactDto(
      id: (json['linkId'] ??
              json['id'] ??
              json['_id'] ??
              json['supervisorUserId'] ??
              supervisor['userId'] ??
              supervisor['_id'] ??
              email)
          .toString(),
      name: _pickFirstNonEmpty([
        supervisor['name']?.toString(),
        supervisor['fullName']?.toString(),
        supervisor['userName']?.toString(),
        fullName,
        email,
      ]),
      email: email,
      status: _pickFirstNonEmpty([
        json['status']?.toString(),
        json['inviteStatus']?.toString(),
        json['state']?.toString(),
        'ACTIVE',
      ]).toUpperCase(),
      permissions: _parsePermissions(json['permissions']),
    );
  }

  List<ContactPermission> _parsePermissions(dynamic rawPermissions) {
    if (rawPermissions is! List) {
      return const [];
    }

    final permissions = <ContactPermission>[];
    for (final item in rawPermissions) {
      final value = item?.toString();
      if (value == null) continue;
      for (final permission in ContactPermission.values) {
        if (permission.apiValue == value) {
          permissions.add(permission);
        }
      }
    }
    return permissions;
  }

  String _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }
}
