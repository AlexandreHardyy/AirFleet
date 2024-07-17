import 'package:dio/dio.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/dio.dart';

class ProposalService {
  static Future<List<Proposal>> getProposals({double? maxPrice, int? minSeatsAvailable}) async {
    var basePath = '/proposals';
    Map<String, dynamic> queryParams = {};
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }
    if (minSeatsAvailable != null) {
      queryParams['min_seats_available'] = minSeatsAvailable.toString();
    }

    String queryString = Uri(queryParameters: queryParams).query;
    String finalPath = basePath + (queryString.isNotEmpty ? '?$queryString' : '');

    try {
      final response = await dioApi.get(
        finalPath,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      final List<dynamic> data = response.data;
      return data.map((proposal) => Proposal.fromJson(proposal)).toList();
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to get proposals: $error');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<List<Proposal>> getProposalsForMe() async {
    try {
      final response = await dioApi.get(
        '/proposals/me',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      final List<dynamic> data = response.data;
      return data.map((proposal) => Proposal.fromJson(proposal)).toList();
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to get proposals: $error');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<Proposal?> getProposalById(int id) async {
    try {
      final response = await dioApi.get(
        '/proposals/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      return Proposal.fromJson(response.data);
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to get proposal: $error');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<Proposal?> createProposal(Map<String, dynamic> data) async {
    try {
      final response = await dioApi.post(
        '/proposals',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      return Proposal.fromJson(response.data);
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to create proposal: $error');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<void> updateProposal(int id, Map<String, dynamic> data) async {
    try {
      await dioApi.patch('/proposals/$id', data: data);
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to update proposal: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<void> deleteProposal(int id) async {
    try {
      await dioApi.delete('/proposals/$id');
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to delete proposal: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<void> joinProposal(int id) async {
    try {
      await dioApi.patch('/proposals/$id/join');
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to join proposal: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<void> leaveProposal(int id) async {
    try {
      await dioApi.patch('/proposals/$id/leave');
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to leave proposal: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<Proposal> startProposal(int id) async {
    try {
      final response = await dioApi.patch(
        '/proposals/$id/start',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      print(response.data);
      return Proposal.fromJson(response.data);
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to leave proposal: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }
}
