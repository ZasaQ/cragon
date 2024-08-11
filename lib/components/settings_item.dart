
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String titleText;
  final TextStyle? titleStyle;
  final String? subtitleText;
  final TextStyle? subtitleStyle;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onTap;
  final bool isExpandable;
  final List<Widget>? expansionTileChildren;

  const SettingsItem({
    super.key,
    required this.titleText,
    this.titleStyle,
    this.subtitleText,
    this.subtitleStyle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.isExpandable = false,
    this.expansionTileChildren,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: isExpandable
          ? ExpansionTile(
              leading: leadingIcon,
              title: Text(
                titleText,
                style: titleStyle ?? const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: (subtitleText != null)
                  ? Text(
                      subtitleText!,
                      style: subtitleStyle ?? Theme.of(context).textTheme.bodyMedium!,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: trailingIcon,
              children: expansionTileChildren ?? []
            )
          : ListTile(
              leading: leadingIcon,
              onTap: onTap,
              title: Text(
                titleText,
                style: titleStyle ?? const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: (subtitleText != null)
                  ? Text(
                      subtitleText!,
                      style: subtitleStyle ?? Theme.of(context).textTheme.bodyMedium!,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: trailingIcon,
            ),
    );
  }
}
