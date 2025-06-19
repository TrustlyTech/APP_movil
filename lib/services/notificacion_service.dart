import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';

class NotificacionService {
  static const String baseUrl = 'https://notificaciones-identity.onrender.com';

  static Future<List<Notificacion>> obtenerNotificaciones(int usuarioId) async {
    final url = Uri.parse('$baseUrl/notificaciones/$usuarioId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List datos = jsonDecode(response.body)['notificaciones'];
      return datos.map((n) => Notificacion.fromJson(n)).toList();
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }

  static Future<void> eliminarNotificacion(int id) async {
    final url = Uri.parse('$baseUrl/notificaciones/$id');
    await http.delete(url);
  }

  static Future<void> eliminarTodas(int usuarioId) async {
    final url = Uri.parse('$baseUrl/notificaciones/usuario/$usuarioId');
    await http.delete(url);
  }
}
