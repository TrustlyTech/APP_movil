import 'package:flutter/material.dart';
import '../../models/notificacion.dart';
import '../../services/notificacion_service.dart';
import '../widgets/ayuda_dialog.dart';

class NotificacionesScreen extends StatefulWidget {
  final int usuarioId;

  const NotificacionesScreen({required this.usuarioId});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _notificaciones;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  void _cargarNotificaciones() {
    setState(() {
      _notificaciones = NotificacionService.obtenerNotificaciones(widget.usuarioId);
    });
  }

  Future<void> _confirmarEliminarTodo() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar todas las notificaciones'),
        content: Text('¿Estás seguro de que deseas eliminar todas las notificaciones?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );

    if (confirmado == true) {
      await NotificacionService.eliminarTodas(widget.usuarioId);
      _cargarNotificaciones();
    }
  }

  void _mostrarAyuda() {
    AyudaDialog.mostrar(
      context: context,
      titulo: 'Ayuda - Notificaciones',
      mensaje: '''
En esta pantalla puedes visualizar todas las notificaciones asociadas a tu cuenta.

• Cada notificación contiene el tipo y el mensaje relacionado.

• Puedes eliminar una notificación individual tocando el ícono rojo de la papelera.

• Si deseas eliminar todas las notificaciones, utiliza el ícono de papelera roja en la parte superior derecha.
''',
    );
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
              Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          leading: BackButton(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.black),
              onPressed: _mostrarAyuda,
              tooltip: 'Ayuda',
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _confirmarEliminarTodo,
              tooltip: 'Eliminar todas',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List<Notificacion>>(
            future: _notificaciones,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar notificaciones'));
              }

              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay notificaciones'));
              }

              final notificaciones = snapshot.data!;
              return ListView.builder(
                itemCount: notificaciones.length,
                itemBuilder: (context, index) {
                  final n = notificaciones[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.blue, size: 36),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.tipo,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                n.mensaje,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await NotificacionService.eliminarNotificacion(n.id);
                            _cargarNotificaciones();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
