import 'package:flutter/material.dart';

class ConfirmacionDenunciaDialog extends StatelessWidget {
  final Future<void> Function() onConfirmar;

  const ConfirmacionDenunciaDialog({Key? key, required this.onConfirmar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Evita ocupar espacio innecesario
        children: [
          SingleChildScrollView(
            child: Text(
              '¿Estás seguro que deseas denunciar a esta persona?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24), // Espacio razonable entre texto y botones
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await onConfirmar();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text('Denunciar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
