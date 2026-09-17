import 'package:flutter/material.dart';

class AppBarTitleAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const AppBarTitleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
}

class AppBarTitleScreen extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<AppBarTitleAction> actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final double titleFontSize;

  const AppBarTitleScreen({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
    this.titleFontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: titleFontSize,
      color: colorScheme.onSurface,
    );

    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      centerTitle: centerTitle,
      titleSpacing: automaticallyImplyLeading ? null : 20,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      ),
      actions: [
        for (final action in actions)
          IconButton(
            tooltip: action.tooltip,
            onPressed: action.onPressed,
            icon: Icon(
              action.icon,
              color: action.color ?? colorScheme.onSurface,
            ),
          ),

        if (actions.isNotEmpty) const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
