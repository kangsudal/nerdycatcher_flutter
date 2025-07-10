import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/app/routes/route_names.dart';
import 'package:nerdycatcher_flutter/pages/signin_viewmodel.dart';

class DefaultAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final bool hasBack;

  const DefaultAppBar({super.key, required this.hasBack});

  @override
  ConsumerState<DefaultAppBar> createState() => _DefaultAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DefaultAppBarState extends ConsumerState<DefaultAppBar> {
  @override
  Widget build(BuildContext context) {
    final signinViewmodel = ref.read(signinViewmodelProvider.notifier);
    return AppBar(
      leading:
          widget.hasBack
              ? IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home'); // 또는 context.goNamed('home')
                  }
                },
                icon: Icon(Icons.arrow_back_ios_new),
              )
              : SizedBox(),
      actions: [
        // IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
        IconButton(
          onPressed: () {
            signinViewmodel.signout();
            if (context.mounted) {
              context.goNamed(RouteNames.signin);
            }
          },
          icon: Icon(Icons.tune),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
