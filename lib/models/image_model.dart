class ImageModel {
  final String path;

  ImageModel({required this.path});

  // Convertir la imagen a un mapa de datos si necesitas enviar otros atributos
  Map<String, dynamic> toJson() {
    return {
      'path': path,
    };
  }
}
