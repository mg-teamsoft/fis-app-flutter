# Theme System

This project uses a **centralized theme system** to ensure visual consistency across the application.  
Instead of hardcoding UI values such as colors, paddings, radius values, or typography styles, all design tokens are accessed through the theme layer.

All theme exports are centralized in a single import:

```dart
import "package:project_name/theme/theme.dart";
```

This keeps imports clean and ensures that the entire team uses the same design tokens.

---

## Accessing the Theme

The theme can be accessed through a **BuildContext extension**.

```dart
final theme = context.appTheme;
```

Flutter's built-in **ColorScheme** is also available through the context:

```dart
final colors = context.colorScheme;
```

Example usage:

```dart
Container(
  padding: EdgeInsets.all(ThemePadding.all10),
  background: context.appTheme.brandPrimary,
  decoration: BoxDecoration(
    color: context.colorScheme.surface,
  ),
)
```

---

## Theme Structure

The theme system is divided into several sections to keep the design system organized.

| Section | Description |
|------|------|
| ColorScheme | Default Flutter color system used for UI colors |
| Extension | Project-specific colors |
| Size | Standart size values |
| Padding | Standard spacing values |
| Radius | Standard border radius values |
| Typography | Text styles used across the app |

These tokens ensure the UI stays consistent across all screens.

---

## Theme Size

### Import
```dart
import "package:<project_name>/theme/theme.dart";
```

### Usage
```dart
final double size = ThemeSize.<Name>
```

| Name | Size | Objective |
|------|------|------|
| spacingXs |8 | Spacing |
| spacingS | 10 | Spacing |
| spacingM | 16 | Spacing |
| spacingL | 20 | Spacing |
| spacingXl | 24| Spacing |
| spacingXXl | 32 | Spacing |
| spacingXXXl | 48 | Spacing |
| iconSmall | 16 | Icon Size |
| iconMedium | 24 | Icon Size |
| iconLarge | 32 | Icon Size |
| iconXL | 48 | Icon Size |
| buttonHeightSmall | 36 | Button Height Size |
| buttonHeightMedium | 48 | Button Height Size  |
| buttonHeightLarge | 56 | Button Height Size  |
| appBarHeight | 56 | AppBar Height Size |
| bottomBarHeight | 72 | Bottom Bar Height Size |
| avatarSmall |32 | Avatar Size |
| avatarMedium | 48 | Avatar Size |
| avatarLarge | 64 | Avatar Size |
| avatarXL | 128 | Avatar Size |
| avatarXXL | 256| Avatar Size |

---

## Theme Radius

### Import
```dart
import "package:<project_name>/theme/theme.dart";
```

### Usage
```dart
final BorderRadius radius = ThemeRadius.<Name>
```

| Name | Radius | Objective |
|------|------|------|
| circular4 | 4 | All Circular |
| circular8 | 8 | All Circular |
| circular12 | 12 | All Circular |
| circular16 | 16 | All Circular |
| circular20 | 20| All Circular |
| circular24 | 24 | All Circular |
| circular32 | 32| All Circular |
| top8 | 8 | Top Circular |
| top8 | 16| Top Circular |
| bottom8 | 8 | Bottom Circular |
| bottom16 | 16| Bottom Circular |

---

## Theme Padding

### Import
```dart
import "package:<project_name>/theme/theme.dart";
```

### Usage
```dart
final EdgeInsets padding = ThemePadding.<Name>
```

| Name | Radius | Objective |
|------|------|------|
| all10 | 10 | All Padding |
| all15 | 8 | All Padding |
| all16 | 12 | All Padding |
| all20 | 16 | All Padding |
| all24 | 20| All Padding |
| all32 | 24 | All Padding |
| horizontalSymmetric | 20| Horizontal Padding |
| horizontalSymmetricMedium | 16 | Horizontal Padding  |
| horizontalSymmetricLarge | 24| Horizontal Padding  |
| verticalSymmetric | 20 | Vertical Padding  |
| verticalSymmetricSmall | 8| Vertical Padding |
| pageVertical8 | 8| Vertical Padding |
| verticalSymmetricMedium | 16 | Vertical Padding |
| verticalSymmetricLarge | 24| Vertical Padding |
| marginBottom8 | 8 | Bottom Margin |
| marginBottom10 | 10| Bottom Margin |
| marginBottom12 | 12 | Bottom Margin |
| marginBottom15 | 15 | Bottom Margin |
| marginBottom16 | 16 | Bottom Margin |
| marginBottom20 | 20 | Bottom Margin |
| marginBottom24 | 24| Bottom Margin |
| marginBottom24 | 32 | Bottom Margin |
| horizontalSymmetricFree | < Size > | Specific Horizontal Padding |
| verticalSymmetricFree | < Size > | Specific Veritcal Padding |
