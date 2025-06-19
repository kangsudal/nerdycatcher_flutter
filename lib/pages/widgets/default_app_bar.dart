import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        // IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
        IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
