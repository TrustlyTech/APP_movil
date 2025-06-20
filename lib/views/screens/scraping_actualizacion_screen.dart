import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/scraping_actualizacion.dart';
import '../../services/scraping_actualizacion_service.dart';
import '../widgets/ayuda_dialog.dart';

class ScrapingActualizacionScreen extends StatefulWidget {
  @override
  _ScrapingActualizacionScreenState createState() => _ScrapingActualizacionScreenState();
}

class _ScrapingActualizacionScreenState extends State<ScrapingActualizacionScreen> {
  late Future<List<ScrapingActualizacion>> _futureActualizaciones;

  @override
  void initState() {
    super.initState();
    _futureActualizaciones = ScrapingActualizacionService().obtenerActualizaciones();
  }

  String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const BackButton(color: Colors.black),
                    const SizedBox(width: 10),
                    Image.asset('assets/tabler_spy.png', width: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "Historial de Scraping",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Colors.black),
                      onPressed: () {
                        AyudaDialog.mostrar(
                          context: context,
                          titulo: 'Ayuda - Historial de Scraping',
                          mensaje: '''Esta pantalla muestra un registro cronológico de las actualizaciones realizadas mediante scraping.

Cada actualización indica el estado del scraping y la fecha exacta en que se ejecutó.

• Si ves estados como "Exitoso", "Fallido" u "Cancelado", estos reflejan el resultado de la ejecución del proceso automático de recolección de datos.

Este historial te permite monitorear si el sistema está funcionando correctamente o si hubo problemas en alguna ejecución.''',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FutureBuilder<List<ScrapingActualizacion>>(
                    future: _futureActualizaciones,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay actualizaciones registradas.'));
                      }

                      final actualizaciones = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: actualizaciones.length,
                        itemBuilder: (context, index) {
                          final act = actualizaciones[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.update, color: Colors.blue),
                              title: Text(
                                act.estado,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(formatearFecha(act.fecha)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              if (!isKeyboardOpen)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text(
                      'Estas son las últimas actualizaciones del scraping.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
