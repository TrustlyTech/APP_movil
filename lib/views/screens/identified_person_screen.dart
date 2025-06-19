import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_gateway_service.dart';
import '../../services/comparacion_service.dart';
import '../../services/denuncias_service.dart';
import '../../services/auth_service.dart';
import 'confirmar_guardar_screen.dart';

class IdentifiedPersonScreen extends StatelessWidget {
  final String name;
  final double confidence;
  final String reward;
  final String imagePath;

  IdentifiedPersonScreen({
    required this.name,
    required this.confidence,
    required this.reward,
    required this.imagePath,
  });

  final DenunciasService _denunciasService = DenunciasService();
  final AuthService _authService = AuthService();

  Future<void> _reportarYLlamar(BuildContext context) async {
    final usuario = _authService.usuarioAutenticado;
    final personId = ApiGatewayService().lastIdentifiedPersonId;

    if (usuario == null || personId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario o personId no disponible')),
      );
      return;
    }

    final requisitoriadoId = await ComparacionService()
        .obtenerRequisitoriadoIdPorPersonId(personId);

    if (requisitoriadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró al requisitoriado')),
      );
      return;
    }

    final exito = await _denunciasService.denunciar(usuario['id'], requisitoriadoId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito ? 'Denuncia enviada' : 'Error al enviar denuncia'),
        backgroundColor: exito ? Colors.green : Colors.red,
      ),
    );

    final hotlineUri = Uri.parse('tel:080040007');
    if (await canLaunchUrl(hotlineUri)) {
      await launchUrl(hotlineUri);
    }
  }

  void _redirigirAConfirmacion(BuildContext context) async {
    final personId = ApiGatewayService().lastIdentifiedPersonId;
    if (personId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el personId')),
      );
      return;
    }

    final requisitoriadoId = await ComparacionService()
        .obtenerRequisitoriadoIdPorPersonId(personId);

    if (requisitoriadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el requisitoriadoId')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConfirmarGuardarScreen(requisitoriadoId: requisitoriadoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Resultados', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coincidencia - Persona requisitoriada',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Nombre: $name'),
                        Text('Coincidencia: ${confidence.toStringAsFixed(1)}%'),
                        Text('Recompensa ofrecida: $reward'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'La persona en la imagen coincide con un registro en el Programa de Recompensas del Mininter.\n'
              'Si tienes información adicional, llama a la línea gratuita o acércate a cualquier comisaría.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reportarYLlamar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Reportar'),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _redirigirAConfirmacion(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
