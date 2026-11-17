import 'package:material_ui/material_ui.dart';

/// Widget ilustrativo animado que muestra un monitor y un teléfono con
/// animaciones de pulso; extraído desde CheckImei para reutilización / limpieza.
class AnimatedDeviceImei extends StatelessWidget {
  const AnimatedDeviceImei({super.key, required this.pulseAnimation});

  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color outline = theme.colorScheme.outline;
    final Color surface = theme.colorScheme.surface;
    final Color highlight = theme.colorScheme.primary;

    return Transform.scale(
      scale: pulseAnimation.value,
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 20,
              top: 20,
              child: _MonitorSurface(
                surface: surface,
                outline: outline,
                highlight: highlight,
              ),
            ),
            const Positioned(
              left: 70,
              bottom: 20,
              child: _BaseRect(width: 20, height: 15, color: Color(0xFFBDBDBD)),
            ),
            Positioned(
              left: 60,
              bottom: 10,
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: _PhoneSurface(highlight: highlight),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitorSurface extends StatelessWidget {
  const _MonitorSurface({
    required this.surface,
    required this.outline,
    required this.highlight,
  });
  final Color surface;
  final Color outline;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outline, width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: highlight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: <Widget>[
                    Container(height: 8, color: const Color(0xFFE0E0E0)),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 20,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 20,
                          height: 20,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneSurface extends StatelessWidget {
  const _PhoneSurface({required this.highlight});
  final Color highlight;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 2),
                    color: const Color(0xFFE0E0E0),
                  ),
                  Container(
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 2),
                    color: const Color(0xFFE0E0E0),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 15,
                    decoration: BoxDecoration(
                      color: highlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseRect extends StatelessWidget {
  const _BaseRect({
    required this.width,
    required this.height,
    required this.color,
  });
  final double width;
  final double height;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: width, height: height, color: color);
}
