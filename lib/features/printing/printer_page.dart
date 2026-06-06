import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'printer_bloc.dart';
import 'widgets/printer_layout.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({super.key, required this.printerArgs});

  final PrinterArguments printerArgs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (printerArgs.onTapBack != null) {
          printerArgs.onTapBack!();
        } else if (printerArgs.onTap != null) {
          printerArgs.onTap!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: ChangeNotifierProvider<PrinterBloc>(
        create: (_) => PrinterBloc(printerArgs: printerArgs),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            title: Text(
              'IMPRESIÓN',
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                if (printerArgs.onTapBack != null) {
                  printerArgs.onTapBack!();
                } else if (printerArgs.onTap != null) {
                  printerArgs.onTap!();
                } else {
                  Navigator.maybePop(context);
                }
              },
            ),
          ),
          body: const PrinterLayout(),
        ),
      ),
    );
  }
}
