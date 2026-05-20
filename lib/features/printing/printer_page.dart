import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/components/tomza_dialog.dart';
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
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => CustomDialog(
            title: printerArgs.backConfirmationTitle ?? 'Regresar',
            description: printerArgs.backConfirmationDescription ??
                '¿Quiere regresar a la pantalla anterior?',
            type: CustomDialogType.warning,
            actions: [
              DialogAction(
                label: 'Cancelar',
                onPressed: () => Navigator.of(context).pop(false),
              ),
              DialogAction(
                label: 'Aceptar',
                onPressed: () => Navigator.of(context).pop(true),
                isPrimary: true,
              ),
            ],
            onAccept: () {},
          ),
        );
        if (confirm == true && context.mounted) {
          if (printerArgs.onTapBack != null) {
            printerArgs.onTapBack!();
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
