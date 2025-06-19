class DenunciaEstadistica {
  final String periodo;
  final int cantidad;

  DenunciaEstadistica({required this.periodo, required this.cantidad});

  factory DenunciaEstadistica.fromJson(Map<String, dynamic> json) {
    return DenunciaEstadistica(
      periodo: json['periodo'],
      cantidad: json['cantidad'],
    );
  }
}

class LocalizacionEstadistica {
  final String nombre;
  final int cantidad;

  LocalizacionEstadistica({required this.nombre, required this.cantidad});

  factory LocalizacionEstadistica.fromJson(Map<String, dynamic> json) {
    return LocalizacionEstadistica(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }
}

class TopRequisitoriado {
  final int id;
  final String nombre;
  final int cantidad;

  TopRequisitoriado({required this.id, required this.nombre, required this.cantidad});

  factory TopRequisitoriado.fromJson(Map<String, dynamic> json) {
    return TopRequisitoriado(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }
}
