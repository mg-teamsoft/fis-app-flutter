import 'package:fis_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';

class WidgetCardInvoice extends StatelessWidget {
  const WidgetCardInvoice(
      {super.key,
      required this.id,
      required this.name,
      required this.amoung,
      required this.date,
      required this.badge,
      this.size = const Size(double.infinity, 80)});

  final String id;
  final String date;
  final String amoung;
  final String? badge;
  final String name;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // Actions to be performed when the card is clicked...
        },
        child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: context.appTheme.cardBackground.withValues(alpha: 0.7),
              borderRadius: ThemeRadius.circular12,
            ),
            padding: ThemePadding.all10(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Expanded(
                  flex: 1,
                  child:Row(


                  children: [
                    
                    SizedBox(
                      width: ThemeSize.avatarMedium,
                      height: ThemeSize.avatarMedium,
                      child: Icon(Icons.receipt_long,
                          size: ThemeSize.iconMedium,
                          color: context.colorScheme.onPrimary),
                    ),


                    Expanded(
                      flex: 1,
                      child:ThemeTypography.titleLarge(
                      context,
                      name,
                      color: context.colorScheme.onSurface,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),)
                    
                  ],
                ),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemeTypography.titleMedium(context, amoung,
                        color: context.colorScheme.onSurface),
                    ThemeTypography.titleMedium(context, date),
                  ],
                )
              ],
            )));
  }
}
