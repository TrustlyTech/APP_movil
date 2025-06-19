class ScrapingActualizacion {
  final String estado;
  final DateTime fecha;

  ScrapingActualizacion({required this.estado, required this.fecha});

  factory ScrapingActualizacion.fromJson(Map<String, dynamic> json) {
    return ScrapingActualizacion(
      estado: json['estado'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}
