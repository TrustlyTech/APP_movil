class Notificacion {
  final int id;
  final String tipo;
  final String mensaje;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.mensaje,
    required this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      tipo: json['tipo'],
      mensaje: json['mensaje'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}
