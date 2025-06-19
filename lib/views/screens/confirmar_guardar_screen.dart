import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/reporte_service.dart';
import 'face_verification_screen.dart';

class ConfirmarGuardarScreen extends StatelessWidget {
  final int requisitoriadoId;

  ConfirmarGuardarScreen({required this.requisitoriadoId});

  void _confirmarGuardado(BuildContext context) async {
    final usuarioId = AuthService().usuarioAutenticado?['id'];

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    final exito = await ReporteService().crearReporte(usuarioId, requisitoriadoId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito
            ? 'Reporte guardado con éxito'
            : 'Ya existe un reporte o falló el guardado'),
      ),
    );

    // Opción 1: Cerrar esta pantalla y volver atrás (como "Cancelar")
    Navigator.pop(context);
    Navigator.pop(context);

    // Opción 2: Si necesitas reiniciar el flujo (descomenta esto)
    /*
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => FaceVerificationScreen()),
      (route) => false,
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro que deseas guardar este reporte?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _confirmarGuardado(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Guardar'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
