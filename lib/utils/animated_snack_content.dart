import 'package:material_ui/material_ui.dart';

class AnimatedSnackContent extends StatefulWidget {
  const AnimatedSnackContent({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  State<AnimatedSnackContent> createState() => _AnimatedSnackContentState();
}

class _AnimatedSnackContentState extends State<AnimatedSnackContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ScaleTransition(
          scale: _scale,
          child: Icon(widget.icon, color: widget.color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.text,
            style: TextStyle(color: widget.color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
