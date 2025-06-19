// lib/models/user_model.dart
class User {
  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String? ciudad;
  final String? pais;
  final String? celular;
  final String? rol;

  User({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    this.ciudad,
    this.pais,
    this.celular,
    this.rol,
  });

  // Convierte JSON a objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      ciudad: json['ciudad'],
      pais: json['pais'],
      celular: json['celular'],
      rol: json['rol'],
    );
  }

  // Convierte objeto User a JSON para enviar en request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'ciudad': ciudad,
      'pais': pais,
      'celular': celular,
      // No enviamos rol porque es asignado por backend
    };
  }
}
