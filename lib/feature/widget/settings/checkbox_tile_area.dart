part of '../../page/settings.dart';

class _SettingsCheckBoxTileArea extends StatefulWidget {
  const _SettingsCheckBoxTileArea({
    required this.suppressChanges,
    required this.hasChanges,
    required this.food,
    required this.meal,
    required this.fuel,
    required this.parking,
    required this.electronic,
    required this.medication,
    required this.stationery,
    required this.makeup,
  });

  final bool food;
  final bool meal;
  final bool fuel;
  final bool parking;
  final bool electronic;
  final bool medication;
  final bool stationery;
  final bool makeup;

  final bool suppressChanges;
  final bool hasChanges;

  @override
  State<_SettingsCheckBoxTileArea> createState() =>
      _SettingsCheckBoxTileAreaState();
}

class _SettingsCheckBoxTileAreaState extends State<_SettingsCheckBoxTileArea> {
  late bool food;
  late bool meal;
  late bool fuel;
  late bool parking;
  late bool electronic;
  late bool medication;
  late bool stationery;
  late bool makeup;

  late bool suppressChanges;
  late bool hasChanges;
  @override
  void initState() {
    super.initState();
    food = widget.food;
    meal = widget.meal;
    fuel = widget.fuel;
    parking = widget.parking;
    electronic = widget.electronic;
    medication = widget.medication;
    stationery = widget.stationery;
    makeup = widget.makeup;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckBoxTile(
          title: ReceiptCategory.food.label,
          value: food,
          onChanged: (value) {
            setState(() {
              food = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.meal.label,
          value: meal,
          onChanged: (value) {
            setState(() {
              meal = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.fuel.label,
          value: fuel,
          onChanged: (value) {
            setState(() {
              fuel = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.parking.label,
          value: parking,
          onChanged: (value) {
            setState(() {
              parking = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.electronic.label,
          value: electronic,
          onChanged: (value) {
            setState(() {
              electronic = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.medication.label,
          value: medication,
          onChanged: (value) {
            setState(() {
              medication = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.stationery.label,
          value: stationery,
          onChanged: (value) {
            setState(() {
              stationery = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
        CheckBoxTile(
          title: ReceiptCategory.personalCare.label,
          value: makeup,
          onChanged: (value) {
            setState(() {
              makeup = value!;
              if (!suppressChanges) hasChanges = true;
            });
          },
        ),
      ],
    );
  }
}
