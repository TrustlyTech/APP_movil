import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart'; // Para usar TextInputFormatter
import '../../services/auth_service.dart';
import '../widgets/PoliticaPrivacidadWidget.dart';
import '../widgets/TerminosCondicionesWidget.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final String _selectedCountry = 'Perú';
  String? _selectedDepartamento;

  final List<String> _departamentosPeru = [
    'Amazonas', 'Áncash', 'Apurímac', 'Arequipa', 'Ayacucho', 'Cajamarca',
    'Callao', 'Cusco', 'Huancavelica', 'Huánuco', 'Ica', 'Junín', 'La Libertad',
    'Lambayeque', 'Lima', 'Loreto', 'Madre de Dios', 'Moquegua', 'Pasco',
    'Piura', 'Puno', 'San Martín', 'Tacna', 'Tumbes', 'Ucayali',
  ];

// ... imports y clase RegisterScreen sin cambios

@override
Widget build(BuildContext context) {
  final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Column(
        children: [
          // Encabezado fijo
          Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 10),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // mismo padding que el formulario
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/tabler_spy.png', width: 30),
            SizedBox(width: 10),
            Text(
              "Registrate",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  ),
),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_nameController, 'Nombre'),
                  _buildTextField(_lastNameController, 'Apellidos'),
                  _buildTextField(_emailController, 'Correo', keyboardType: TextInputType.emailAddress),
                  _buildPasswordField(),
                  _buildFixedCountryDropdown(),
                  _buildDepartamentoDropdown(),
                  _buildTextField(
                    _phoneController,
                    'Celular',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Al registrarte, aceptas nuestros ',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Términos y Condiciones',
                            style: TextStyle(
                              color: Colors.blue,
                              
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TerminosCondicionesWidget()),
                                );
                              },
                          ),
                          TextSpan(text: ' y nuestra '),
                          TextSpan(
                            text: 'Política de Privacidad.',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
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
  );
}

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE0E0E0),
          hintText: 'Contraseña',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        items: [DropdownMenuItem(value: 'Perú', child: Text('Perú'))],
        onChanged: null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE0E0E0),
          hintText: 'País',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartamento,
        items: _departamentosPeru.map((dep) => DropdownMenuItem(value: dep, child: Text(dep))).toList(),
        onChanged: (value) => setState(() => _selectedDepartamento = value),
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE0E0E0),
          hintText: 'Departamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
    final phoneValid = RegExp(r"^9\d{8}$").hasMatch(phone);

    if (_nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        email.isEmpty ||
        !emailValid ||
        _passwordController.text.trim().isEmpty ||
        _selectedDepartamento == null ||
        phone.isEmpty ||
        !phoneValid) {
      String errorMessage = 'Por favor, completa todos los campos';
      if (!emailValid) errorMessage = 'Por favor, ingresa un correo válido';
      if (!phoneValid) errorMessage = 'Celular debe comenzar con 9 y tener 9 dígitos';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerResult = await authService.registerUser(
        nombre: _nameController.text.trim(),
        apellidos: _lastNameController.text.trim(),
        correo: email,
        contrasena: _passwordController.text.trim(),
        ciudad: _selectedDepartamento!,
        pais: _selectedCountry,
        celular: phone,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(registerResult['mensaje'] ?? 'Registro exitoso')),
      );

      await authService.loginUser(
        correo: email,
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
    _phoneController.dispose();
    super.dispose();
  }
}
