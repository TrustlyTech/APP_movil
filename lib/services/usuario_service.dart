import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String baseUrl = 'https://user-identity-toib.onrender.com'; // reemplaza por tu URL real

  Future<bool> actualizarUsuario(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuario/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}
