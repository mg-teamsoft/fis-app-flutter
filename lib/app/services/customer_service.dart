import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';

class CustomerListItemDto {
  CustomerListItemDto({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class CustomerService {
  CustomerService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<CustomerListItemDto>> fetchCustomers({
    ContactPermission permission = ContactPermission.viewReceipts,
  }) async {
    try {
      final response = await _api.dio.get<dynamic>(
        '/api/supervisor/customers',
        queryParameters: {
          'permission': permission.apiValue,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Müşteri listesi alınamadı');
      }

      final items = _extractItems(response.data);
      return items
          .map(_mapCustomer)
          .where((customer) => customer.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Müşteri listesi alınamadı');
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      const candidateKeys = ['data', 'items', 'customers', 'results'];
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

  CustomerListItemDto _mapCustomer(Map<String, dynamic> json) {
    final firstName = json['firstName']?.toString().trim();
    final lastName = json['lastName']?.toString().trim();
    final fullName = [firstName, lastName]
        .where((part) => part != null && part.isNotEmpty)
        .cast<String>()
        .join(' ');

    return CustomerListItemDto(
      id: _pickFirstNonEmpty([
        json['customerUserId']?.toString(),
        json['customerId']?.toString(),
        json['userId']?.toString(),
        json['id']?.toString(),
        json['_id']?.toString(),
      ]),
      name: _pickFirstNonEmpty([
        json['name']?.toString(),
        json['fullName']?.toString(),
        json['userName']?.toString(),
        fullName,
        json['email']?.toString(),
      ]),
    );
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
