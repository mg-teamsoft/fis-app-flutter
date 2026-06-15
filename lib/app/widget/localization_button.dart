import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/feature/enum/localization.dart';
import 'package:fis_app_flutter/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class LocalizationButton extends StatefulWidget {
  const LocalizationButton({super.key});

  @override
  State<LocalizationButton> createState() => _LocalizationButtonState();
}

class _LocalizationButtonState extends State<LocalizationButton> {

  late EnumLocalization _localization;

    @override
    void initState() {
      super.initState();
    }
  
    @override
    void dispose() {
      super.dispose();
    }
  
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _localization = EnumLocalization.values.firstWhere(
      (e) => e.locale == LocaleSettings.currentLocale,
    );
    }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      builder: (context, controller, child) {
        return FilledButton.tonal(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_localization.icon),
              const SizedBox(width: 8),
              Text(_localization.label),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
      menuChildren: EnumLocalization.values.map((localization) {
        return MenuItemButton(
          onPressed: () async {
            await LocaleSettings.setLocale(localization.locale);
          },
          child: Row(
            children: [
              Text(localization.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              ThemeTypography.bodyLarge(context, localization.label),
            ],
          ),
        );
      }).toList(),
    );
  }
  
}
