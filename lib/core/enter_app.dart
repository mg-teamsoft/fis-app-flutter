final class CoreEnterApp {
  String? req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null;
  String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Zorunlu alan';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim());
    return ok ? null : 'E-posta adresi geçersiz';
  }

  String? validatePassword(String? value) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}$');

    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (!regex.hasMatch(value)) {
      return 'Use min 8 chars, at least (1 uppercase & 1 lowercase & 1 number & 1 special) char.';
    }
    return null;
  }
}
