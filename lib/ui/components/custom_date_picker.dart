import 'package:material_ui/material_ui.dart';

import 'package:intl/intl.dart';

/// Extensión para detectar si es móvil
extension BuildContextExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
}

/// Widget customizado para selección de fechas con restricciones específicas
class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    required this.onDateChanged,
    super.key,
    this.initialDate,
    this.title = 'Seleccionar Fecha',
    this.storeCode,
    required this.titleStore,
    required this.icon,
  });

  /// Callback que se ejecuta cuando cambia la fecha seleccionada
  final Function(DateTime) onDateChanged;

  /// Fecha inicial a mostrar en el calendario
  final DateTime? initialDate;

  /// Título del diálogo
  final String title;

  /// Código de la tienda (opcional, para mostrar en el diálogo)
  final String? storeCode;

  final String titleStore;

  final IconData icon;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  /// Fecha actual del sistema
  DateTime get _currentDate => DateTime.now();

  /// Fecha máxima permitida (5 años en el futuro)
  DateTime get _maximumDate => DateTime(_currentDate.year + 5, 12, 31);

  /// Formateador de fecha para mostrar en español
  String get _formattedSelectedDate {
    return DateFormat(
      'EEEE, dd \'de\' MMMM \'de\' yyyy',
      'es_ES',
    ).format(_selectedDate);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? _currentDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 500,
        height: isMobile ? 400 : 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Información de la tienda (si se proporciona)
              if (widget.storeCode != null) ...<Widget>[
                _buildStoreInfo(isMobile),
                SizedBox(height: isMobile ? 16 : 24),
              ],

              // Fecha seleccionada
              _buildSelectedDateInfo(isMobile),
              SizedBox(height: isMobile ? 12 : 20),

              // Calendario customizado
              _buildCustomCalendar(isMobile),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        _buildCancelButton(isMobile),
        _buildConfirmButton(isMobile),
      ],
      actionsPadding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 16 : 20,
      ),
    );
  }

  /// Widget que muestra la información de la tienda
  Widget _buildStoreInfo(bool isMobile) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.15 : 0.08,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            widget.icon,
            color: theme.colorScheme.primary,
            size: isMobile ? 20 : 28,
          ),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.titleStore,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  widget.storeCode!,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget que muestra la fecha seleccionada
  Widget _buildSelectedDateInfo(bool isMobile) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(
          alpha: isDark ? 0.15 : 0.08,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.secondary,
            size: isMobile ? 18 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fecha seleccionada:',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  _formattedSelectedDate,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calendario personalizado que muestra todos los días
  Widget _buildCustomCalendar(bool isMobile) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: isMobile ? 4 : 12,
            offset: Offset(0, isMobile ? 1 : 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildCalendarHeader(isMobile),
          SizedBox(height: isMobile ? 8 : 12),
          _buildWeekdaysHeader(isMobile),
          SizedBox(height: isMobile ? 4 : 8),
          _buildCalendarGrid(isMobile),
        ],
      ),
    );
  }

  /// Header del calendario con navegación de mes
  Widget _buildCalendarHeader(bool isMobile) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: _canNavigateToPreviousMonth() ? _previousMonth : null,
          icon: Icon(
            Icons.chevron_left,
            size: isMobile ? 24 : 28,
            color: _canNavigateToPreviousMonth()
                ? theme.colorScheme.primary
                : theme.disabledColor,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy', 'es_ES').format(_currentMonth),
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: _canNavigateToNextMonth() ? _nextMonth : null,
          icon: Icon(
            Icons.chevron_right,
            size: isMobile ? 24 : 28,
            color: _canNavigateToNextMonth()
                ? theme.colorScheme.primary
                : theme.disabledColor,
          ),
        ),
      ],
    );
  }

  /// Header con los días de la semana
  Widget _buildWeekdaysHeader(bool isMobile) {
    final ThemeData theme = Theme.of(context);
    final List<String> weekdays = <String>[
      'LUN',
      'MAR',
      'MIÉ',
      'JUE',
      'VIE',
      'SÁB',
      'DOM',
    ];

    return Row(
      children: weekdays
          .map(
            (String day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Grid del calendario con todos los días
  Widget _buildCalendarGrid(bool isMobile) {
    final int daysInMonth = _getDaysInMonth();
    final int firstDayWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
    ).weekday;
    final int startOffset = firstDayWeekday - 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 42, // 6 semanas × 7 días
      itemBuilder: (BuildContext context, int index) {
        if (index < startOffset || index >= startOffset + daysInMonth) {
          return const SizedBox(); // Días vacíos
        }

        final int day = index - startOffset + 1;
        final DateTime date = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          day,
        );
        final bool isSelected = _isSameDay(date, _selectedDate);
        final bool isToday = _isSameDay(date, _currentDate);
        final bool isEnabled = _isDateEnabled(date);

        return _buildDayCell(
          day,
          isSelected,
          isToday,
          isEnabled,
          date,
          isMobile,
        );
      },
    );
  }

  /// Celda individual para cada día
  Widget _buildDayCell(
    int day,
    bool isSelected,
    bool isToday,
    bool isEnabled,
    DateTime date,
    bool isMobile,
  ) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: isEnabled ? () => _selectDate(date) : null,
      child: Container(
        margin: EdgeInsets.all(isMobile ? 1 : 2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: isSelected || isToday
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : isEnabled
                  ? theme.colorScheme.onSurface
                  : theme.disabledColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene el número de días en el mes actual
  int _getDaysInMonth() {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  /// Verifica si dos fechas son el mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Verifica si una fecha está habilitada
  bool _isDateEnabled(DateTime date) {
    return date.isAfter(_currentDate.subtract(const Duration(days: 1))) &&
        date.isBefore(_maximumDate.add(const Duration(days: 1)));
  }

  /// Selecciona una fecha
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  /// Navega al mes anterior
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  /// Navega al mes siguiente
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  /// Verifica si se puede navegar al mes anterior
  bool _canNavigateToPreviousMonth() {
    final DateTime previousMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month - 1,
    );
    return previousMonth.isAfter(
      DateTime(_currentDate.year, _currentDate.month - 1, 0),
    );
  }

  /// Verifica si se puede navegar al mes siguiente
  bool _canNavigateToNextMonth() {
    final DateTime nextMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
    );
    return nextMonth.isBefore(_maximumDate);
  }

  /// Botón de cancelar
  Widget _buildCancelButton(bool isMobile) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('Cancelar', style: TextStyle(fontSize: isMobile ? 14 : 16)),
    );
  }

  /// Botón de confirmar
  Widget _buildConfirmButton(bool isMobile) {
    return ElevatedButton(
      onPressed: () {
        widget.onDateChanged(_selectedDate);
        Navigator.of(context).pop();
      },
      child: Text('Confirmar', style: TextStyle(fontSize: isMobile ? 14 : 16)),
    );
  }
}
