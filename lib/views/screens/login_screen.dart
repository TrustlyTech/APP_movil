import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../services/auth_service.dart';
import '../../views/screens/face_verification_screen.dart';
import 'recuperar_password_screen.dart';
import '../widgets/PoliticaPrivacidadWidget.dart';
import '../widgets/TerminosCondicionesWidget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final authService = AuthService();

  void _validateEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black.withOpacity(0.3),
          selectionHandleColor: Colors.black,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/tabler_spy.png', width: 30),
                    SizedBox(width: 10),
                    Text(
                      "Iniciar sesión",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'abcd123@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    suffixIcon: _isEmailValid
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    showDialog(
  context: context,
  builder: (_) => RecuperarPasswordDialog(),
);
                  },
                  child: Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("O"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Crear cuenta nueva", style: TextStyle(fontSize: 16)),
                  ),
                ),
                Spacer(),
                if (!isKeyboardOpen)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Al registrarte, aceptas nuestros ',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          children: [
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TerminosCondicionesWidget()),
                                  );
                                },
                            ),
                            TextSpan(text: ' \ny nuestra '),
                            TextSpan(
                              text: 'Política de Privacidad.',
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PoliticaPrivacidadWidget()),
                                  );
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
  FocusScope.of(context).unfocus();

  if (!_isEmailValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor, ingresa un correo válido'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  if (_passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor, ingresa la contraseña'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final result = await authService.loginUser(
      correo: _emailController.text.trim(),
      contrasena: _passwordController.text.trim(),
    );

    if (result != null && result['exito'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Inicio de sesión exitoso'),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FaceVerificationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['error'] ?? 'Credenciales incorrectas'),
          backgroundColor: Colors.red,
        ),
      );
      _passwordController.clear();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error del servidor: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
