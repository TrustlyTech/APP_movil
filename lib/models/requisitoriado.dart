import 'dart:convert';
import 'dart:typed_data';

class Requisitoriado {
  final int id;
  final String nombre;
  final String recompensa;
  final String imagen;

  Requisitoriado({
    required this.id,
    required this.nombre,
    required this.recompensa,
    required this.imagen,
  });

  factory Requisitoriado.fromJson(Map<String, dynamic> json) {
    return Requisitoriado(
      id: json['id'],
      nombre: json['nombre'],
      recompensa: json['recompensa'],
      imagen: json['imagen'],
    );
  }

  Uint8List decodedImage() {
    final base64Str = imagen.split(',').last; // Remueve el 'data:image/png;base64,'
    return base64Decode(base64Str);
  }
}
