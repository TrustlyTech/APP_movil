import 'dart:convert';
import 'dart:typed_data';

class Reporte {
  final int id;
  final int requisitoriadoId;
  final String nombre;
  final String recompensa;
  final String imagen; // Base64 con encabezado: 'data:image/png;base64,...'

  Reporte({
    required this.id,
    required this.requisitoriadoId,
    required this.nombre,
    required this.recompensa,
    required this.imagen,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'],
      requisitoriadoId: json['requisitoriado_id'],
      nombre: json['nombre'],
      recompensa: json['recompensa'],
      imagen: json['imagen'],
    );
  }

  Uint8List decodedImage() {
    final base64Str = imagen.split(',').last; // Quita encabezado tipo 'data:image/png;base64,'
    return base64Decode(base64Str);
  }
}
