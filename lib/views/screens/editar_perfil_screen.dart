import 'package:flutter/material.dart';
import '../../services/usuario_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  EditarPerfilScreen({required this.usuario});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController apellidosController;
  late TextEditingController correoController;
  late TextEditingController ciudadController;
  late TextEditingController paisController;
  late TextEditingController celularController;
  late TextEditingController contrasenaController;
  late TextEditingController confirmarContrasenaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.usuario['nombre']);
    apellidosController = TextEditingController(text: widget.usuario['apellidos']);
    correoController = TextEditingController(text: widget.usuario['correo']);
    ciudadController = TextEditingController(text: widget.usuario['ciudad'] ?? '');
    paisController = TextEditingController(text: widget.usuario['pais'] ?? '');
    celularController = TextEditingController(text: widget.usuario['celular'] ?? '');
    contrasenaController = TextEditingController();
    confirmarContrasenaController = TextEditingController();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    ciudadController.dispose();
    paisController.dispose();
    celularController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nombre": nombreController.text,
        "apellidos": apellidosController.text,
        "correo": correoController.text,
        "ciudad": ciudadController.text,
        "pais": paisController.text,
        "celular": celularController.text,
      };
      if (contrasenaController.text.isNotEmpty) {
        data['contrasena'] = contrasenaController.text;
      }

      setState(() => _isLoading = true);
      final exito = await UsuarioService().actualizarUsuario(widget.usuario['id'], data);
      setState(() => _isLoading = false);

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos actualizados con éxito'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            duration: Duration(milliseconds: 800),
          ),
        );
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context, data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar usuario'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          ),
        );
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFE0E0E0),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: validator ??
            (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/tabler_spy.png', width: 24),
            const SizedBox(width: 8),
            const Text(
              'Editar Perfil',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTextField(nombreController, 'Nombre'),
                      _buildTextField(apellidosController, 'Apellidos'),
                      _buildTextField(correoController, 'Correo', keyboardType: TextInputType.emailAddress),
                      _buildTextField(ciudadController, 'Departamento'),
                      _buildTextField(paisController, 'País'),
                      _buildTextField(celularController, 'Celular', keyboardType: TextInputType.phone),
                      _buildTextField(
                        contrasenaController,
                        'Nueva Contraseña',
                        obscureText: true,
                        required: false,
                      ),
                      _buildTextField(
                        confirmarContrasenaController,
                        'Confirmar Contraseña',
                        obscureText: true,
                        required: false,
                        validator: (value) {
                          if (contrasenaController.text.isNotEmpty && value != contrasenaController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (!isKeyboardOpen)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Revisa bien tus datos antes de guardar.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
