import 'package:flutter/material.dart';

class PoliticaPrivacidadWidget extends StatelessWidget {
  const PoliticaPrivacidadWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Text(
            '''
Política de Privacidad

Nos tomamos tu privacidad muy en serio. Esta política describe cómo recopilamos, usamos y protegemos tus datos personales:

1. Datos Recopilados:
   - Recopilamos tu nombre, apellidos, correo, país, ciudad y número de celular.
   - También recopilamos imágenes faciales para verificación de identidad.

2. Uso de los Datos:
   - Los datos son utilizados exclusivamente para fines de verificación de identidades y seguridad del sistema.
   - No vendemos ni compartimos tu información con terceros sin tu consentimiento.

3. Almacenamiento y Seguridad:
   - La información se almacena de forma segura en bases de datos protegidas.
   - Se aplican medidas técnicas para proteger tus datos contra accesos no autorizados.

4. Derechos del Usuario:
   - Puedes solicitar la corrección o eliminación de tus datos en cualquier momento, escribiéndonos a nuestro canal de soporte.

5. Servicios de Terceros:
   - Utilizamos servicios como Azure Face API, los cuales también cumplen con normas internacionales de privacidad.

Al continuar usando la aplicación, aceptas nuestra política de privacidad.

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
