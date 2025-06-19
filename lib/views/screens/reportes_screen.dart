import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/reporte_model.dart';
import '../../services/reporte_service.dart';

class ListaReportesScreen extends StatefulWidget {
  final int usuarioId;
  const ListaReportesScreen({Key? key, required this.usuarioId}) : super(key: key);

  @override
  State<ListaReportesScreen> createState() => _ListaReportesScreenState();
}

class _ListaReportesScreenState extends State<ListaReportesScreen> {
  List<Reporte> _reportes = [];
  final _reporteService = ReporteService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    final reportes = await _reporteService.obtenerReportesPorUsuario(widget.usuarioId);
    setState(() {
      _reportes = reportes;
      _isLoading = false;
    });
  }

  void _callHotline() async {
    final Uri hotlineUri = Uri.parse('tel:080040007');
    if (await canLaunchUrl(hotlineUri)) {
      await launchUrl(hotlineUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar la llamada')),
      );
    }
  }

  void _reportar(Reporte reporte) {
    _callHotline();
  }

  void _eliminar(Reporte reporte) async {
    final exito = await _reporteService.eliminarReporte(reporte.id);
    if (exito) {
      _cargarReportes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/tabler_spy.png', width: 30),
              SizedBox(width: 10),
              Text('Reportes', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          leading: BackButton(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _reportes.isEmpty
                  ? Center(child: Text('No hay reportes disponibles.'))
                  : ListView.builder(
                      itemCount: _reportes.length,
                      itemBuilder: (context, index) {
                        final reporte = _reportes[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  reporte.decodedImage(),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reporte.nombre,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Recompensa: ${reporte.recompensa}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _reportar(reporte),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(90, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text('Reportar'),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _eliminar(reporte),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(90, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
