class AppValidator {
  // Valida texto no vacío
  static String? validateNotEmpty(
    String? value, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  // Valida formato de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es obligatorio';

    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  // Valida fortaleza de contraseña (mínimo 8 caracteres, con mayúscula, número y carácter especial)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Incluya una mayúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Incluya un número';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Incluya un carácter especial (!@#\$%^&*)';
    }

    return null;
  }

  // Valida número de teléfono guatemalteco (+502 XXXXXXXX)
  static String? validateGuatemalaPhone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es obligatorio';

    // Eliminar espacios en blanco si los hubiera
    final cleanedValue = value.replaceAll(RegExp(r'\s+'), '');

    // Validar que sean exactamente 8 dígitos
    if (!RegExp(r'^\d{8}$').hasMatch(cleanedValue)) {
      return 'Debe tener 8 dígitos';
    }

    // Validar que el primer dígito sea válido (2,3,5,7 u 8)
    /* final firstDigit = cleanedValue.substring(0, 1);
    if (!['2', '3', '5', '7', '8'].contains(firstDigit)) {
      return 'El número debe comenzar con 2, 3, 5, 7 u 8';
    } */

    return null;
  }

  // Valida fecha en formato dd/mm/yyyy o mm/dd/yyyy
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'La fecha es obligatoria';

    // Regex para dd/mm/yyyy o mm/dd/yyyy
    final dateRegex = RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$|^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/\d{4}$',
    );

    if (!dateRegex.hasMatch(value)) {
      return 'Formato de fecha inválido (dd/mm/yyyy o mm/dd/yyyy)';
    }

    // Validar que la fecha sea real
    final parts = value.split('/');
    int day, month, year;

    if (parts[0].length == 2) {
      // dd/mm/yyyy
      day = int.parse(parts[0]);
      month = int.parse(parts[1]);
    } else {
      // mm/dd/yyyy
      month = int.parse(parts[0]);
      day = int.parse(parts[1]);
    }
    year = int.parse(parts[2]);

    if (month < 1 || month > 12) return 'Mes inválido';
    if (day < 1 || day > 31) return 'Día inválido';

    // Días por mes
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) daysInMonth[1] = 29;

    if (day > daysInMonth[month - 1]) return 'Día inválido para el mes';

    return null;
  }

  // Valida hora en formato HH:mm
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) return 'La hora es obligatoria';

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');

    if (!timeRegex.hasMatch(value)) {
      return 'Formato de hora inválido (HH:mm)';
    }

    return null;
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
