import 'package:flutter/material.dart';

class AyudaDialog {
  static void mostrar({
    required BuildContext context,
    required String titulo,
    required String mensaje,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
