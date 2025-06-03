import 'package:dio/dio.dart';

class PokemonRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  PokemonRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getPokemonList(int offset, int limit) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/pokemon',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw Exception('Error fetching Pokemon list: $e');
    }
  }

  Future<Map<String, dynamic>> getPokemonById(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/pokemon/$id');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching Pokemon by ID: $e');
    }
  }

  Future<Map<String, dynamic>> getPokemonByName(String name) async {
    try {
      final response = await _dio.get('$_baseUrl/pokemon/$name');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching Pokemon by name: $e');
    }
  }

  Future<Map<String, dynamic>> getPokemonByType(String type) async {
    try {
      final response = await _dio.get('$_baseUrl/type/$type');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching Pokemon by type: $e');
    }
  }
}
