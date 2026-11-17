import 'package:material_ui/material_ui.dart';

/// Enumeración para los tipos de filtro de fecha
enum DateFilter { today, tomorrow, custom, none }

extension DateFilterNameExtension on DateFilter {
  String get name {
    switch (this) {
      case DateFilter.today:
        return 'Hoy';
      case DateFilter.tomorrow:
        return 'Mañana';
      case DateFilter.custom:
        return 'Personalizado';
      case DateFilter.none:
        return 'Ninguno';
    }
  }
}

extension DateFilterIconExtension on DateFilter {
  IconData get icon {
    switch (this) {
      case DateFilter.today:
        return Icons.today;
      case DateFilter.tomorrow:
        return Icons.today_sharp;
      case DateFilter.custom:
        return Icons.date_range;
      case DateFilter.none:
        return Icons.clear_all;
    }
  }
}

extension DateFilterColorExtension on DateFilter {
  Color get color {
    switch (this) {
      case DateFilter.today:
        return Colors.blue.shade600;
      case DateFilter.tomorrow:
        return Colors.green.shade600;
      case DateFilter.custom:
        return Colors.orange.shade600;
      case DateFilter.none:
        return Colors.grey.shade600;
    }
  }
}

/// Obtiene el título apropiado cuando no hay resultados para el filtro
extension DateFilterEmptyTitleExtension on DateFilter {
  String get emptyTitle {
    switch (this) {
      case DateFilter.today:
        return 'Sin visitas para hoy';
      case DateFilter.tomorrow:
        return 'Sin visitas para mañana';
      case DateFilter.custom:
        return 'Sin visitas para la fecha';
      case DateFilter.none:
        return 'Sin Visitas Programadas';
    }
  }
}

/// Obtiene el mensaje apropiado cuando no hay resultados para el filtro
extension DateFilterEmptyMessageExtension on DateFilter {
  String get emptyMessage {
    switch (this) {
      case DateFilter.today:
        return 'No tienes visitas programadas para hoy';
      case DateFilter.tomorrow:
        return 'No tienes visitas programadas para mañana';
      case DateFilter.custom:
        return 'No hay visitas programadas para la fecha seleccionada';
      case DateFilter.none:
        return 'Cuando programes visitas aparecerán aquí';
    }
  }
}
