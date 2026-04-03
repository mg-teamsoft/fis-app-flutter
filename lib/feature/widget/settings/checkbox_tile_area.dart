part of '../../page/settings.dart';

class _SettingsCheckBoxTileArea extends StatefulWidget {
  const _SettingsCheckBoxTileArea({
    required this.food,
    required this.meal,
    required this.fuel,
    required this.parking,
    required this.electronic,
    required this.medication,
    required this.stationery,
    required this.makeup,
    required this.onChanged,
  });

  final bool food;
  final bool meal;
  final bool fuel;
  final bool parking;
  final bool electronic;
  final bool medication;
  final bool stationery;
  final bool makeup;

  final VoidCallback onChanged;

  @override
  State<_SettingsCheckBoxTileArea> createState() =>
      _SettingsCheckBoxTileAreaState();
}

class _SettingsCheckBoxTileAreaState extends State<_SettingsCheckBoxTileArea> {
  late bool food = widget.food;
  late bool meal = widget.meal;
  late bool fuel = widget.fuel;
  late bool parking = widget.parking;
  late bool electronic = widget.electronic;
  late bool medication = widget.medication;
  late bool stationery = widget.stationery;
  late bool makeup = widget.makeup;

  void _handleUpdate(VoidCallback updateAction) {
    setState(() {
      updateAction();
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckBoxTile(
          title: ReceiptCategory.food.label,
          value: food,
          onChanged: (value) => _handleUpdate(() => food = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.meal.label,
          value: meal,
          onChanged: (value) => _handleUpdate(() => meal = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.fuel.label,
          value: fuel,
          onChanged: (value) => _handleUpdate(() => fuel = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.parking.label,
          value: parking,
          onChanged: (value) => _handleUpdate(() => parking = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.electronic.label,
          value: electronic,
          onChanged: (value) => _handleUpdate(() => electronic = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.medication.label,
          value: medication,
          onChanged: (value) => _handleUpdate(() => medication = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.stationery.label,
          value: stationery,
          onChanged: (value) => _handleUpdate(() => stationery = value!),
        ),
        CheckBoxTile(
          title: ReceiptCategory.personalCare.label,
          value: makeup,
          onChanged: (value) => _handleUpdate(() => makeup = value!),
        ),
      ],
    );
  }
}
