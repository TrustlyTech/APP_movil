import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'estadisticas_screen.dart';
import 'editar_perfil_screen.dart';
import 'scraping_actualizacion_screen.dart'; // NUEVA IMPORTACIÓN

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final usuario = authService.usuarioAutenticado;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/tabler_spy.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (usuario != null && usuario['rol'] == 'administrador') ...[
            IconButton(
              icon: Image.asset('assets/scraping.png', width: 24, height: 24), // Nuevo ícono desde imagen
              tooltip: 'Reportes Scraping',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScrapingActualizacionScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.black),
              tooltip: 'Estadísticas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EstadisticasScreen()),
                );
              },
            ),
          ]
        ],
      ),
      body: usuario == null
          ? const Center(child: Text('No hay datos de usuario.'))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundImage: const AssetImage('assets/login.png'),
                              backgroundColor: Colors.grey[200],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${usuario['nombre']} ${usuario['apellidos']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfo('Nombre:', usuario['nombre']),
                      _buildInfo('Apellidos:', usuario['apellidos']),
                      _buildInfo('Correo:', usuario['correo']),
                      _buildInfo('Ciudad:', usuario['ciudad']),
                      _buildInfo('País:', usuario['pais']),
                      _buildInfo('Celular:', usuario['celular']),
                      _buildInfo('Rol:', usuario['rol'] ?? 'usuario'),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditarPerfilScreen(usuario: usuario)),
                            );
                          },
                          child: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value ?? 'No disponible'),
          ],
        ),
      ),
    );
  }
}
