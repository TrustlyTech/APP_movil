import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:facelab/services/api_gateway_service.dart';

class ComparacionService {
  // Singleton: constructor privado y una instancia estática única
  ComparacionService._privateConstructor();
  static final ComparacionService _instance = ComparacionService._privateConstructor();
  factory ComparacionService() => _instance;

  final String _url = 'https://reportes-requisitoriados.onrender.com/requisitoriado_id_por_person';

  // Variable para guardar el ID del requisitoriado
  int? requisitoriadoId;

  // Método para obtener el ID a partir del personId y almacenarlo
  Future<int?> obtenerRequisitoriadoIdPorPersonId(String personId) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"personId": personId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exito'] == true) {
          requisitoriadoId = data['id'];  // Se guarda aquí
          return requisitoriadoId;
        } else {
          print('Error del servidor: ${data['error']}');
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener el ID del requisitoriado: $e');
    }
    return null;
  }
}
