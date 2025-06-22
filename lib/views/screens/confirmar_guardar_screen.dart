import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/reporte_service.dart';
import 'face_verification_screen.dart';

class ConfirmarGuardarDialog extends StatelessWidget {
  final int requisitoriadoId;

  const ConfirmarGuardarDialog({Key? key, required this.requisitoriadoId}) : super(key: key);

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

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: Text(
              '¿Estás seguro que deseas guardar este reporte?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
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
    );
  }
}
