import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scraping_actualizacion.dart';

class ScrapingActualizacionService {
  static const String baseUrl = 'https://notificaciones-identity.onrender.com';

  Future<List<ScrapingActualizacion>> obtenerActualizaciones() async {
    final response = await http.get(Uri.parse('$baseUrl/scraping-actualizacion'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> lista = data['actualizaciones'];
      return lista.map((e) => ScrapingActualizacion.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar las actualizaciones');
    }
  }
}
