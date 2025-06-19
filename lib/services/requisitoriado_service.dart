import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requisitoriado.dart';

class RequisitoriadoService {
  final String baseUrl = "https://reportes-requisitoriados.onrender.com";

  Future<Map<String, dynamic>> getRequisitoriados({
    int page = 1,
    int limit = 5,
    String? nombre,
  }) async {
    String url = '$baseUrl/requisitoriados?page=$page&limit=$limit';

    if (nombre != null && nombre.isNotEmpty) {
      final encoded = Uri.encodeQueryComponent(nombre);
      url += '&nombre=$encoded';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = (data['requisitoriados'] as List)
          .map((item) => Requisitoriado.fromJson(item))
          .toList();

      return {
        'lista': items,
        'tieneAnterior': data['tiene_anterior'],
        'tieneSiguiente': data['tiene_siguiente'],
        'pagina': data['pagina'],
        'total_paginas': data['total_paginas'],
      };
    } else {
      throw Exception('Error al obtener requisitoriados');
    }
  }
}
