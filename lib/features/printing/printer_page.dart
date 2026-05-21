import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'printer_bloc.dart';
import 'widgets/printer_layout.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({super.key, required this.printerArgs});

  final PrinterArguments printerArgs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (didPop == true && context.mounted) {
          if (printerArgs.onTapBack != null) {
            printerArgs.onTapBack!();
          } else if (printerArgs.onTap != null) {
            printerArgs.onTap!();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: ChangeNotifierProvider<PrinterBloc>(
        create: (_) => PrinterBloc(printerArgs: printerArgs),
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Impresión'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            body: const PrinterLayout(),
          ),
        ),
      ),
    );
  }
}
