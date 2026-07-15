import 'package:flutter/material.dart';

class PrintButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const PrintButton({
    super.key,
    required this.onPressed,
    this.label = 'Imprimir',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.print),
      label: Text(label),
    );
  }
}
