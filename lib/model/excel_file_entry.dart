class ExcelFileEntry {
  // e.g., "Eylül 25"

  ExcelFileEntry({
    required this.idOrKey,
    required this.fileName,
    required this.sheetName,
    this.customerUserId,
  });
  final String idOrKey; // mongo _id or s3Key (used to presign)
  final String fileName; // display name, e.g., "Ad Soyad-FİŞ LİSTESİ.xlsx"
  final String sheetName;
  final String? customerUserId;
}
