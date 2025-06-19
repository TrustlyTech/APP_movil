import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../views/screens/face_verification_screen.dart';  // Ajusta el path según tu proyecto

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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Color(0xFFEEEEEE),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "¿No tienes una cuenta? Regístrate",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isKeyboardOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'By signing up, you agree to our ',
                        style: TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'T&Cs',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(color: Colors.blue),
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
    );
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus(); // Ocultar teclado

    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un correo válido')),
      );
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa la contraseña')),
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
          SnackBar(content: Text(result['mensaje'] ?? 'Inicio de sesión exitoso')),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FaceVerificationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['error'] ?? 'Credenciales incorrectas')),
        );
        _passwordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error del servidor: ${e.toString()}')),
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
