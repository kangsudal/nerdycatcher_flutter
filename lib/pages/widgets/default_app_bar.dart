import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasBack;

  const DefaultAppBar({super.key, required this.hasBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          hasBack
              ? IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.arrow_back_ios_new),
              )
              : SizedBox(),
      actions: [
        // IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
        IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
