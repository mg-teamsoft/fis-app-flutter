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

class ContactInviteDto {
  ContactInviteDto({
    required this.id,
    required this.inviteeEmail,
    required this.status,
    required this.permissions,
    required this.expiresAt,
    required this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String inviteeEmail;
  final String status;
  final List<String> permissions;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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

  Future<void> removeSupervisorAccess(String supervisorUserId) async {
    final normalizedSupervisorUserId = supervisorUserId.trim();
    if (normalizedSupervisorUserId.isEmpty) {
      throw Exception('Geçerli bir danışman kimliği bulunamadı');
    }

    try {
      final response = await _api.dio.delete<Map<String, dynamic>>(
        '/api/contacts/supervisors/$normalizedSupervisorUserId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erişim kaldırılamadı');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Erişim kaldırılamadı');
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

  Future<List<ContactInviteDto>> fetchInvites() async {
    try {
      final response =
          await _api.dio.get<Map<String, dynamic>>('/api/contacts/invites');
      if (response.statusCode != 200) {
        throw Exception('Davetler alınamadı');
      }

      final items = _extractInviteList(response.data);
      return items.map(_mapInvite).toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Davetler alınamadı');
    }
  }

  Future<void> resendInvite(String inviteId) async {
    final normalizedInviteId = inviteId.trim();
    if (normalizedInviteId.isEmpty) {
      throw Exception('Geçerli bir davet kimliği bulunamadı');
    }

    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/api/contacts/invites/$normalizedInviteId/resend',
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Davet yeniden gönderilemedi');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Davet yeniden gönderilemedi');
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

  List<Map<String, dynamic>> _extractInviteList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final invites = data['invites'];
      if (invites is List) {
        return invites
            .whereType<Map<String, dynamic>>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }

    return _extractContactList(data);
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
      id: (json['supervisorUserId'] ??
              supervisor['userId'] ??
              supervisor['_id'] ??
              json['linkId'] ??
              json['id'] ??
              json['_id'] ??
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

  ContactInviteDto _mapInvite(Map<String, dynamic> json) {
    return ContactInviteDto(
      id: (json['inviteId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      inviteeEmail: _pickFirstNonEmpty([
        json['inviteeEmail']?.toString(),
        json['email']?.toString(),
      ]),
      status: _pickFirstNonEmpty([
        json['status']?.toString(),
        'PENDING',
      ]).toUpperCase(),
      permissions: (json['permissions'] is List)
          ? (json['permissions'] as List)
              .map((item) => item?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList()
          : const [],
      expiresAt: _parseDateTime(json['expiresAt']),
      respondedAt: _parseDateTime(json['respondedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
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

  DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}
