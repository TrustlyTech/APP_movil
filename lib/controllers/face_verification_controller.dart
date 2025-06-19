import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:facelab/services/api_gateway_service.dart';

class FaceVerificationController {
  final ApiGatewayService _apiGatewayService = ApiGatewayService();

  Future<Map<String, dynamic>> captureAndSendImage(XFile imageFile) async {
    try {
      // Convertir XFile a File para enviarlo a través del servicio
      File imageFileConverted = File(imageFile.path);
      Map<String, dynamic> response = await _apiGatewayService.sendImageToApi(imageFileConverted);

      if (response.containsKey('error')) {
        print('Error al enviar la imagen: ${response['error']}');
      } else {
        print('Imagen enviada correctamente y procesada.');
      }
      return response;
    } catch (e) {
      print('Error al enviar la imagen: $e');
      return {'error': 'Error al enviar la imagen'};
    }
  }
}
