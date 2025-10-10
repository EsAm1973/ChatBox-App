import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:flutter/material.dart';

class RecoverPassButton extends StatelessWidget {
  const RecoverPassButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return CustomBottom(
      text: 'Recover password',
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      onTap: onPressed,
    );
  }
}
