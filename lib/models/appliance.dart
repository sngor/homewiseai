class Appliance {
  String? name;
  String? type;
  String? modelNumber;
  String? serialNumber;
  DateTime? purchaseDate;
  List<String>? maintenanceHistory;
  String? extractedLabelText;

  Appliance({
    this.name,
    this.type,
    this.modelNumber,
    this.serialNumber,
    this.purchaseDate,
    this.maintenanceHistory,
    this.extractedLabelText,
  });
}