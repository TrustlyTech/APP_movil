import 'dart:convert';
import 'package:http/http.dart' as http;

class DenunciasService {
  static const String baseUrl = 'https://reportes-requisitoriados.onrender.com';

  Future<bool> denunciar(int usuarioId, int requisitoriadoId) async {
    final uri = Uri.parse('$baseUrl/denuncias');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'requisitoriado_id': requisitoriadoId,
      }),
    );
    return resp.statusCode == 200;
  }
}
