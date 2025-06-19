import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Singleton: una sola instancia compartida
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String baseUrl = 'https://user-identity-toib.onrender.com';

  // Usuario autenticado (guardado tras login)
  Map<String, dynamic>? _usuarioAutenticado;

  // Getter público
  Map<String, dynamic>? get usuarioAutenticado => _usuarioAutenticado;

  // Setter (opcional si necesitas modificar manualmente desde otros lados)
  set usuarioAutenticado(Map<String, dynamic>? usuario) {
    _usuarioAutenticado = usuario;
  }

  // Registro de usuario
  Future<Map<String, dynamic>> registerUser({
    required String nombre,
    required String apellidos,
    required String correo,
    required String contrasena,
    String? ciudad,
    String? pais,
    String? celular,
  }) async {
    final url = Uri.parse('$baseUrl/registrar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellidos': apellidos,
          'correo': correo,
          'contrasena': contrasena,
          'ciudad': ciudad,
          'pais': pais,
          'celular': celular,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 409) {
        throw Exception(responseBody['error'] ?? 'Ya existe un usuario con ese correo o celular.');
      } else if (response.statusCode == 400) {
        throw Exception(responseBody['error'] ?? 'Faltan campos requeridos.');
      } else {
        throw Exception(responseBody['error'] ?? 'Error desconocido al registrar.');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }

  // Login de usuario y obtención de perfil completo desde la respuesta
  Future<Map<String, dynamic>> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    final urlLogin = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        urlLogin,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['exito'] == true) {
        _usuarioAutenticado = responseBody['usuario'];
        return responseBody;
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        throw Exception(responseBody['error'] ?? 'Credenciales incorrectas o campos faltantes.');
      } else {
        throw Exception(responseBody['error'] ?? 'Error desconocido al iniciar sesión.');
      }
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // Cierre de sesión
  Future<void> logout() async {
    _usuarioAutenticado = null;

    // Si usas almacenamiento persistente, límpialo aquí:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
  }
}
