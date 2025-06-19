// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  final authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
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
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/tabler_spy.png', width: 30),
                          SizedBox(width: 10),
                          Text("Registrate", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 40),
                      _buildTextField(_nameController, 'Nombre'),
                      _buildTextField(_lastNameController, 'Apellidos'),
                      _buildTextField(_emailController, 'Correo', keyboardType: TextInputType.emailAddress),
                      _buildTextField(_passwordController, 'Contraseña', obscureText: true),
                      _buildTextField(_cityController, 'Ciudad'),
                      _buildTextField(_countryController, 'País'),
                      _buildTextField(_phoneController, 'Celular', keyboardType: TextInputType.phone),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Registrate", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isKeyboardOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'By signing up, you agree to our ',
                        style: TextStyle(fontSize: 12),
                        children: [
                          TextSpan(text: 'T&Cs', style: TextStyle(color: Colors.blue)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy.', style: TextStyle(color: Colors.blue)),
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

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE0E0E0),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    if (_nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, completa todos los campos')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerResult = await authService.registerUser(
        nombre: _nameController.text.trim(),
        apellidos: _lastNameController.text.trim(),
        correo: _emailController.text.trim(),
        contrasena: _passwordController.text.trim(),
        ciudad: _cityController.text.trim(),
        pais: _countryController.text.trim(),
        celular: _phoneController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(registerResult['mensaje'] ?? 'Registro exitoso')),
      );

      await authService.loginUser(
        correo: _emailController.text.trim(),
        contrasena: _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
