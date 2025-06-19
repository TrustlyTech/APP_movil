import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:facelab/controllers/face_verification_controller.dart';
import 'identified_person_screen.dart';
import 'profile_screen.dart';
import 'reportes_screen.dart';
import '../../services/auth_service.dart';
import 'notificaciones_screen.dart';

class FaceVerificationScreen extends StatefulWidget {
  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
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
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile imageFile = await _cameraController!.takePicture();
        Map<String, dynamic> response = await _controller.captureAndSendImage(imageFile);

        if (response.containsKey('message') && response['message'] == "Coincidencia encontrada") {
          Navigator.push(
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Sin Coincidencia'),
                content: Text('La persona no se encuentra requisitoriada en el programa de recompensas del Mininter.'),
                actions: [
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator()),

          // Barra superior
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
                // Ícono de notificaciones
      IconButton(
        icon: Icon(Icons.notifications, color: Colors.black),
        onPressed: () {
          final usuario = AuthService().usuarioAutenticado;
if (usuario != null && usuario['id'] != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NotificacionesScreen(usuarioId: usuario['id']),
    ),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Usuario no autenticado')),
  );
}

        },
      ),
                // Ícono de lista de reportes
                IconButton(
                  icon: Icon(Icons.list, color: Colors.black),
                  onPressed: () {
                    final usuario = AuthService().usuarioAutenticado;
                    if (usuario != null && usuario['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaReportesScreen(usuarioId: usuario['id']),
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

          // Botón flash
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
                    onPressed: _identify,
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

