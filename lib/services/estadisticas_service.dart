import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/estadistica_model.dart';

class EstadisticasService {
  static const String baseUrl = 'https://analytics-identity.onrender.com';

  static Future<List<DenunciaEstadistica>> getDenunciasPorPeriodo(String intervalo) async {
    final response = await http.get(Uri.parse('$baseUrl/estadisticas/denuncias?intervalo=$intervalo'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['estadisticas'] as List;
      return data.map((e) => DenunciaEstadistica.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener denuncias');
    }
  }

  static Future<List<LocalizacionEstadistica>> getEstadisticasLocalizacion(String tipo) async {
    final response = await http.get(Uri.parse('$baseUrl/estadisticas/localizacion?tipo=$tipo'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['estadisticas'] as List;
      return data.map((e) => LocalizacionEstadistica.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener localización');
    }
  }

  static Future<List<TopRequisitoriado>> getTopRequisitoriados() async {
    final response = await http.get(Uri.parse('$baseUrl/estadisticas/top_requisitoriados'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['top_requisitoriados'] as List;
      return data.map((e) => TopRequisitoriado.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener top requisitoriados');
    }
  }
}
