import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Widget sencillo para "sacudir" su child cuando cambia [tick].
class ShakeOnChange extends StatelessWidget {
  const ShakeOnChange({super.key, required this.tick, required this.child});
  final int tick;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Usamos Key para reiniciar la animación cuando cambia el tick
    return TweenAnimationBuilder<double>(
      key: ValueKey(tick),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (_, t, child) =>
          Transform.translate(offset: _shakeOffset(t), child: child),
      child: child,
    );
  }
}

Offset _shakeOffset(double t) {
  // t en [0..1]
  if (t < 0.25) {
    final p = t / 0.25;
    final x = lerpDouble(-8, 8, p)!;
    return Offset(x, 0);
  } else if (t < 0.5) {
    final p = (t - 0.25) / 0.25;
    final x = lerpDouble(8, -8, p)!;
    return Offset(x, 0);
  } else if (t < 0.75) {
    final p = (t - 0.5) / 0.25;
    final x = lerpDouble(-4, 4, p)!;
    return Offset(x, 0);
  } else {
    final p = (t - 0.75) / 0.25;
    final x = lerpDouble(4, 0, p)!;
    return Offset(x, 0);
  }
}
