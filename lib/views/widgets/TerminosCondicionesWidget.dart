import 'package:flutter/material.dart';

class TerminosCondicionesWidget extends StatelessWidget {
  const TerminosCondicionesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Text(
            '''
Términos y Condiciones

Bienvenido a nuestra aplicación. Al utilizar esta app, aceptas cumplir con los siguientes términos y condiciones:

1. Uso del Servicio:
   - Esta aplicación está destinada a la verificación de identidades mediante tecnologías de reconocimiento facial.
   - El uso indebido del sistema, como reportes falsos o suplantación de identidad, está estrictamente prohibido.

2. Responsabilidad del Usuario:
   - Eres responsable de la veracidad de la información que proporcionas.
   - Cualquier intento de manipular el sistema o utilizarlo con fines ilícitos puede conllevar sanciones.

3. Disponibilidad:
   - Nos reservamos el derecho de modificar, suspender o descontinuar cualquier funcionalidad de la aplicación sin previo aviso.

4. Cuenta de Usuario:
   - Debes mantener la confidencialidad de tus credenciales. No compartas tu cuenta con terceros.

5. Aceptación:
   - Al registrarte y utilizar esta aplicación, aceptas estos términos. Si no estás de acuerdo, no utilices el servicio.

Última actualización: Junio de 2025
''',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
