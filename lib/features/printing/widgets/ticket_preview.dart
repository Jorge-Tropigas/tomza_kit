import 'package:flutter/material.dart';
import '../print_models.dart';

class TicketPreview extends StatelessWidget {
  final List<PrintItem> items;
  const TicketPreview({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is PrintText) {
          return ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(item.text),
          );
        }
        if (item is PrintQr) {
          return const ListTile(
            leading: Icon(Icons.qr_code),
            title: Text('QR'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
