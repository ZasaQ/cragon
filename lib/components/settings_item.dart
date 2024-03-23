
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String titleText;
  final TextStyle? titleStyle;
  final String? subtitleText;
  final TextStyle? subtitleStyle;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.titleText,
    this.titleStyle,
    this.subtitleText,
    this.subtitleStyle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: ListTile(
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