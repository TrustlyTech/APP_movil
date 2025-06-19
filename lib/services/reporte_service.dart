import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:facelab/models/reporte_model.dart';

class ReporteService {
  final String _baseUrl = 'https://reportes-requisitoriados.onrender.com';

  // Crear reporte
  Future<bool> crearReporte(int usuarioId, int requisitoriadoId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reportes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "usuario_id": usuarioId,
        "requisitoriado_id": requisitoriadoId,
      }),
    );

    if (response.statusCode == 200) {
      print("Reporte creado exitosamente");
      return true;
    } else {
      print("Error al crear reporte: ${response.body}");
      return false;
    }
  }

  // Eliminar reporte
  Future<bool> eliminarReporte(int reporteId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/reportes/$reporteId'),
    );

    if (response.statusCode == 200) {
      print("Reporte eliminado");
      return true;
    } else {
      print("Error al eliminar reporte: ${response.body}");
      return false;
    }
  }

  // Obtener reportes por usuario
  Future<List<Reporte>> obtenerReportesPorUsuario(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reportes/$usuarioId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reportesJson = data['reportes'];
      return reportesJson.map((json) => Reporte.fromJson(json)).toList();
    } else {
      print("Error al obtener reportes: ${response.body}");
      return [];
    }
  }
}
