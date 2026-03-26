enum ReceiptCategory {
  food('YİYECEK'),
  meal('YEMEK'),
  fuel('AKARYAKIT'),
  parking('OTOPARK'),
  electronic('ELEKTRONİK'),
  medication('İLAÇ'),
  stationery('KIRTASİYE'),
  personalCare('KİŞİSEL BAKIM');

  const ReceiptCategory(this.label);
  final String label;
}
