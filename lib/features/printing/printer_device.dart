class PrinterDevice {
  PrinterDevice({required this.id, required this.name});
  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PrinterDeviceInfo {
  PrinterDeviceInfo({required this.name, required this.address});

  factory PrinterDeviceInfo.fromMap(Map data) => PrinterDeviceInfo(
    name: data['name'] as String? ?? 'Unknown',
    address: data['address'] as String? ?? '',
  );
  final String name;
  final String address;

  // Compare devices by MAC address for consistent selection behavior
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterDeviceInfo &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}
