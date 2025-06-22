import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class RecuperarPasswordDialog extends StatefulWidget {
  @override
  _RecuperarPasswordDialogState createState() => _RecuperarPasswordDialogState();
}

class _RecuperarPasswordDialogState extends State<RecuperarPasswordDialog> {
  final _correoController = TextEditingController();
  final _celularController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  bool _usuarioVerificado = false;
  int? _usuarioId;

  final authService = AuthService();

  Future<void> verificarUsuario() async {
  final correo = _correoController.text.trim();
  final celular = _celularController.text.trim();

  final res = await authService.verificarUsuarioRecuperacion(correo, celular);
  if (res['exito']) {
    setState(() {
      _usuarioVerificado = true;
      _usuarioId = res['usuario_id'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['mensaje']),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['error']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> restablecerContrasena() async {
  final nueva = _nuevaContrasenaController.text.trim();
  final res = await authService.restablecerContrasenaDirecto(_usuarioId!, nueva);
  if (res['exito']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['mensaje']),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['error']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // ... tus imports y clase inicial sin cambios ...

@override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    insetPadding: EdgeInsets.all(20),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Fila con logo, título y X para cerrar
            Row(
              children: [
                Image.asset('assets/tabler_spy.png', width: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Recuperar contraseña",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField(_correoController, 'Correo electrónico', keyboardType: TextInputType.emailAddress),
            _buildTextField(
              _celularController,
              'Celular',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
            ),
            SizedBox(height: 20),
            if (!_usuarioVerificado)
              _buildButton("Verificar usuario", verificarUsuario),
            if (_usuarioVerificado) ...[
              _buildTextField(_nuevaContrasenaController, 'Nueva contraseña', obscureText: true),
              SizedBox(height: 20),
              _buildButton("Restablecer contraseña", restablecerContrasena),
            ],
          ],
        ),
      ),
    ),
  );
}


  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE0E0E0),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _celularController.dispose();
    _nuevaContrasenaController.dispose();
    super.dispose();
  }
}
