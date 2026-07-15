import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.illustration,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String message;
  final Widget? illustration; // Could be an Image.asset or Icon
  final EmptyAction? primaryAction;
  final EmptyAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Corporate-like palette (blue/yellow), but use theme-aware tones
    final Color brandBlue = theme.colorScheme.primary;
    final Color mutted =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : Colors.black54);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illustration
              if (illustration != null)
                SizedBox(
                  height: 160,
                  child: FittedBox(fit: BoxFit.contain, child: illustration!),
                )
              else
                Icon(Icons.inbox_outlined, size: 120, color: mutted),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: mutted),
              ),

              const SizedBox(height: 20),

              // Actions
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (primaryAction != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: primaryAction!.onPressed,
                      icon: Icon(primaryAction!.icon, color: Colors.white),
                      label: Text(primaryAction!.label),
                    ),
                  if (secondaryAction != null)
                    OutlinedButton.icon(
                      onPressed: secondaryAction!.onPressed,
                      icon: Icon(
                        secondaryAction!.icon,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                      label: Text(
                        secondaryAction!.label,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyAction {
  const EmptyAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

// Helper constructors
EmptyAction primary(String label, IconData icon, VoidCallback onPressed) =>
    EmptyAction(label: label, icon: icon, onPressed: onPressed);
EmptyAction secondary(String label, IconData icon, VoidCallback onPressed) =>
    EmptyAction(label: label, icon: icon, onPressed: onPressed);
