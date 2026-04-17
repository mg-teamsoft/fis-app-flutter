enum ProductTypeEnum {
  consumable('Tüketilebilir'),
  nonConsumable('Tüketilemez'),
  subscription('Abonelik'),
  monthly('Aylık'),
  yearly('Yıllık'),
  free('Ücretsiz'),
  unknown('');

  const ProductTypeEnum(this.translation);
  final String translation;

  static ProductTypeEnum fromString(String value) {
    final lower = value.toLowerCase();
    if (lower == 'non_consumable' || lower == 'nonconsumable') {
      return ProductTypeEnum.nonConsumable;
    }
    if (lower.contains('consumable') || lower.contains('additional')) {
      return ProductTypeEnum.consumable;
    }
    if (lower == 'subscription') {
      return ProductTypeEnum.subscription;
    }
    switch (lower) {
      case 'monthly':
      case 'aylik':
        return ProductTypeEnum.monthly;
      case 'yearly':
      case 'yillik':
        return ProductTypeEnum.yearly;
      case 'free':
      case 'ucretsiz':
        return ProductTypeEnum.free;
      default:
        return ProductTypeEnum.unknown;
    }
  }

  static String translate(String value) {
    final type = fromString(value);
    if (type == ProductTypeEnum.unknown) {
      return value;
    }
    return type.translation;
  }
}
