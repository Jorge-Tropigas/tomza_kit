import 'package:flutter/material.dart';

import 'package:tomza_kit/ui/components/tomza_button.dart';

class TomzaActionsButtons extends StatelessWidget {
  const TomzaActionsButtons({
    super.key,
    required this.acceptTitle,
    required this.cancelTitle,
    required this.onAccept,
    this.onCancel,
    this.isAcceptLoading = false,
    this.dense = true,
    this.textColor = Colors.white,
  });

  final String acceptTitle;
  final String cancelTitle;
  final VoidCallback onAccept;
  final VoidCallback? onCancel;
  final bool isAcceptLoading;
  final bool dense;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final TomzaTextButton cancelBtn = TomzaTextButton(
      key: const ValueKey<String>('action_buttons_cancel'),
      label: cancelTitle,
      onPressed: onCancel ?? () => Navigator.of(context).pop(),
      size: dense ? AppButtonSize.dense : AppButtonSize.regular,
      textColor: textColor,
    );
    final TomzaPrimaryButton acceptBtn = TomzaPrimaryButton(
      key: const ValueKey<String>('action_buttons_accept'),
      label: acceptTitle,
      onPressed: onAccept,
      isLoading: isAcceptLoading,
      size: dense ? AppButtonSize.dense : AppButtonSize.regular,
      textColor: textColor,
    );
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[cancelBtn, acceptBtn],
    );
  }
}
