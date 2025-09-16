import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChoosePictureAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChoosePictureAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => GoRouter.of(context).pop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}