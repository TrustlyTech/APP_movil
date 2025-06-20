import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController celularController;
  late TextEditingController contrasenaController;
  late TextEditingController confirmarContrasenaController;

  final String _selectedCountry = 'Perú';
  String? _selectedDepartamento;

  bool _isLoading = false;

  final List<String> _departamentosPeru = [
    'Amazonas', 'Áncash', 'Apurímac', 'Arequipa', 'Ayacucho', 'Cajamarca',
    'Callao', 'Cusco', 'Huancavelica', 'Huánuco', 'Ica', 'Junín', 'La Libertad',
    'Lambayeque', 'Lima', 'Loreto', 'Madre de Dios', 'Moquegua', 'Pasco',
    'Piura', 'Puno', 'San Martín', 'Tacna', 'Tumbes', 'Ucayali',
  ];

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.usuario['nombre']);
    apellidosController = TextEditingController(text: widget.usuario['apellidos']);
    correoController = TextEditingController(text: widget.usuario['correo']);
    celularController = TextEditingController(text: widget.usuario['celular']);
    contrasenaController = TextEditingController();
    confirmarContrasenaController = TextEditingController();
    _selectedDepartamento = widget.usuario['ciudad'];
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    celularController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    final email = correoController.text.trim();
    final phone = celularController.text.trim();
    final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
    final phoneValid = RegExp(r"^9\d{8}$").hasMatch(phone);

    if (!_formKey.currentState!.validate() || _selectedDepartamento == null || !emailValid || !phoneValid) {
      String errorMessage = 'Completa todos los campos correctamente';
      if (!emailValid) errorMessage = 'Correo inválido';
      if (!phoneValid) errorMessage = 'Celular inválido (debe empezar con 9 y tener 9 dígitos)';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    final data = {
      "nombre": nombreController.text.trim(),
      "apellidos": apellidosController.text.trim(),
      "correo": email,
      "ciudad": _selectedDepartamento!,
      "pais": _selectedCountry,
      "celular": phone,
    };
    if (contrasenaController.text.isNotEmpty) {
      data['contrasena'] = contrasenaController.text;
    }

    setState(() => _isLoading = true);
    final exito = await UsuarioService().actualizarUsuario(widget.usuario['id'], data);
    setState(() => _isLoading = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos actualizados con éxito'), backgroundColor: Colors.green),
      );
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context, data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar usuario'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator ??
            (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
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
            SizedBox(width: 8),
            Text('Editar Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      _buildTextField(nombreController, 'Nombre'),
                      _buildTextField(apellidosController, 'Apellidos'),
                      _buildTextField(
                        correoController,
                        'Correo',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildFixedCountryDropdown(),
                      _buildDepartamentoDropdown(),
                      _buildTextField(
                        celularController,
                        'Celular',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                      ),
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
                          if (contrasenaController.text.isNotEmpty &&
                              value != contrasenaController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (!isKeyboardOpen)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
