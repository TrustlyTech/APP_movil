import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:facelab/services/comparacion_service.dart';

class ApiGatewayService {
  // Singleton
  ApiGatewayService._privateConstructor();
  static final ApiGatewayService _instance = ApiGatewayService._privateConstructor();
  factory ApiGatewayService() => _instance;

  final String apiUrl = 'https://verify-n10t.onrender.com/detect_and_identify';

  // Variable para guardar el último personId identificado
  String? lastIdentifiedPersonId;

  // Enviar la imagen al API Gateway y devolver la respuesta
  Future<Map<String, dynamic>> sendImageToApi(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      var picture = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(picture);

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        // Procesar la respuesta JSON
        Map<String, dynamic> jsonResponse = json.decode(responseData.body);
        print(' Imagen enviada correctamente al API Gateway');

        // Guardar personId si existe
        if (jsonResponse.containsKey('personId') && jsonResponse['personId'] != null) {
          lastIdentifiedPersonId = jsonResponse['personId'];
          print(' Person ID guardado: $lastIdentifiedPersonId');
        }

        return jsonResponse;

      } else {
        print(' Error al enviar la imagen: ${response.statusCode}');
        return {
          "error": "No se pudo procesar la imagen correctamente",
          "status": response.statusCode
        };
      }
    } catch (e) {
      print(' Excepción al enviar la imagen: $e');
      throw Exception("Error al enviar la imagen: $e");
    }
  }
}
