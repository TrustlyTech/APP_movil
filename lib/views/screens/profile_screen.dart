import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'estadisticas_screen.dart';
import 'editar_perfil_screen.dart';
import 'scraping_actualizacion_screen.dart';
import '../widgets/ayuda_dialog.dart'; // IMPORTANTE: Ajusta la ruta si es necesario

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  Map<String, dynamic>? usuario;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final authUser = authService.usuarioAutenticado;
    if (authUser != null && authUser['id'] != null) {
      final user = await authService.obtenerUsuarioPorId(authUser['id']);
      setState(() {
        usuario = user;
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('No hay datos de usuario.')),
      );
    }

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
          if (usuario!['rol'] == 'administrador') ...[
            IconButton(
              icon: Image.asset('assets/scraping.png', width: 24, height: 24),
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
          ],
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            tooltip: 'Ayuda',
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        '${usuario!['nombre']} ${usuario!['apellidos']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfo('Nombre:', usuario!['nombre']),
                _buildInfo('Apellidos:', usuario!['apellidos']),
                _buildInfo('Correo:', usuario!['correo']),
                _buildInfo('Departamento:', usuario!['ciudad']),
                _buildInfo('País:', usuario!['pais']),
                _buildInfo('Celular:', usuario!['celular']),
                _buildInfo('Rol:', usuario!['rol'] ?? 'usuario'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditarPerfilScreen(usuario: usuario!)),
                      );
                      await _cargarUsuario();
                    },
                    child: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      await authService.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
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

  void _mostrarAyuda() {
    AyudaDialog.mostrar(
      context: context,
      titulo: 'Ayuda - Perfil',
      mensaje: '''
Aquí puedes:

• Ver tu información personal registrada.
• Editar tu nombre, correo, ciudad, país y más.
• Cerrar sesión si ya no deseas continuar.

Presiona "Editar Perfil" para actualizar tu información.
''',
    );
  }
}
