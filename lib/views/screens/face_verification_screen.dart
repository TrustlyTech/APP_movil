import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:facelab/controllers/face_verification_controller.dart';
import 'identified_person_screen.dart';
import 'profile_screen.dart';
import 'reportes_screen.dart';
import '../../services/auth_service.dart';
import 'notificaciones_screen.dart';
import '../widgets/SinCoincidenciaDialog.dart';
import '../widgets/ayuda_dialog.dart';

class FaceVerificationScreen extends StatefulWidget {
  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  String? _capturedImagePath;
  final FaceVerificationController _controller = FaceVerificationController();
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCameraSafely();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _initializeCameraSafely() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
        await _cameraController!.setFlashMode(_flashMode);
      } else {
        print('No se encontraron cámaras disponibles');
      }
    } catch (e) {
      print('Error al inicializar la cámara: $e');
    }
  }

  Future<void> _resetCameraPreview() async {
    setState(() {
      _capturedImagePath = null;
      _isCameraInitialized = false;
    });
    await _cameraController?.dispose();
    await _initializeCameraSafely();
  }

  Future<void> _setFlashMode(FlashMode mode) async {
    _flashMode = mode;
    if (_cameraController != null) {
      try {
        await _cameraController!.setFlashMode(mode);
        setState(() {});
      } catch (e) {
        print('Error al cambiar flash: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _identify() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_isTakingPicture) {
      setState(() {
        _isTakingPicture = true;
        _capturedImagePath = null;
      });

      try {
        XFile imageFile = await _cameraController!.takePicture();

        setState(() {
          _capturedImagePath = imageFile.path;
        });

        Map<String, dynamic> response =
            await _controller.captureAndSendImage(imageFile);

        if (response.containsKey('message') &&
            response['message'] == "Coincidencia encontrada") {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IdentifiedPersonScreen(
                name: response['name'],
                confidence: response['confidence'] * 100,
                reward: response['userData'],
                imagePath: imageFile.path,
              ),
            ),
          );
        } else {
          await showDialog(
            context: context,
            builder: (BuildContext context) => const SinCoincidenciaDialog(),
          );
        }

        await _resetCameraPreview();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onPressed}) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.6),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized && _cameraController != null
              ? SizedBox.expand(
                  child: _capturedImagePath != null
                      ? Image.file(
                          File(_capturedImagePath!),
                          fit: BoxFit.cover,
                        )
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize!.height,
                            height: _cameraController!.value.previewSize!.width,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                )
              : Center(child: CircularProgressIndicator()),

          // Barra superior con botón de ayuda
          Container(
            height: 100,
            color: Colors.white,
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Row(
              children: [
                Image.asset('assets/tabler_spy.png', width: 30, height: 30),
                SizedBox(width: 10),
                Text(
                  'Verificación facial',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.help_outline, color: Colors.black),
                  tooltip: 'Ayuda',
                  onPressed: () {
                    AyudaDialog.mostrar(
                      context: context,
                      titulo: 'Ayuda de Verificación Facial',
mensaje:
  '🔎 Esta pantalla permite realizar una verificación facial utilizando inteligencia artificial para identificar posibles coincidencias con personas buscadas.\n\n'
  '📸 cámara: Tócalo para capturar una foto. Asegúrate de que el rostro esté centrado, iluminado y sin obstrucciones (como gafas oscuras o gorras).\n\n'
  '⚡ Icono de flash: Cambia entre modo apagado, automático y encendido para mejorar la iluminación al tomar la foto.\n\n'
  '🔔 Icono de notificaciones: Muestra alertas relacionadas con reportes y resultados de tus verificaciones anteriores.\n\n'
  '📋 Icono de reportes: Accede a tus reportes realizados y su estado.\n\n'
  '📄 Botón de requisitoriados: Visualiza la lista de personas actualmente buscadas por las autoridades.\n\n'
  '👤 Botón de perfil: Accede a tu perfil personal, donde puedes ver y editar tu información registrada.\n\n'
  '✅ Si se detecta una coincidencia, se mostrará una pantalla con los detalles del sujeto (nombre, recompensa, nivel de coincidencia, etc.).\n\n'
  '❌ Si no se detecta ninguna coincidencia, se mostrará un mensaje informativo.\n\n'
  'ℹ️ Esta herramienta está destinada a colaborar con la seguridad ciudadana. Utilízala con responsabilidad.',

                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    final usuario = AuthService().usuarioAutenticado;
                    if (usuario != null && usuario['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificacionesScreen(usuarioId: usuario['id']),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuario no autenticado')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.list, color: Colors.black),
                  onPressed: () {
                    final usuario = AuthService().usuarioAutenticado;
                    if (usuario != null && usuario['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListaReportesScreen(usuarioId: usuario['id']),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuario no autenticado')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Botón de flash
          Positioned(
            top: 113,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: Icon(
                  _flashMode == FlashMode.off
                      ? Icons.flash_off
                      : _flashMode == FlashMode.auto
                          ? Icons.flash_auto
                          : Icons.flash_on,
                  color: Colors.white,
                ),
                onPressed: () {
                  FlashMode nextMode;
                  if (_flashMode == FlashMode.off) {
                    nextMode = FlashMode.auto;
                  } else if (_flashMode == FlashMode.auto) {
                    nextMode = FlashMode.always;
                  } else {
                    nextMode = FlashMode.off;
                  }
                  _setFlashMode(nextMode);
                },
              ),
            ),
          ),

          // Botones inferiores
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFloatingButton(
                  icon: Icons.list_alt,
                  onPressed: () => Navigator.pushNamed(context, '/requisitoriados'),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                    onPressed: _isTakingPicture ? null : _identify,
                  ),
                ),
                _buildFloatingButton(
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
