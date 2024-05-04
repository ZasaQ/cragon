import 'package:cragon/components/settings_item.dart';
import 'package:flutter/material.dart';


class SettingsGroup extends StatelessWidget {
  final String? settingsGroupTitle;
  final TextStyle? settingsGroupTitleStyle;
  final List<SettingsItem> items;
  final EdgeInsets? margin;

  const SettingsGroup({
    super.key,
    this.settingsGroupTitle,
    this.settingsGroupTitleStyle,
    required this.items,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (settingsGroupTitle != null)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  settingsGroupTitle!,
                  style: (settingsGroupTitleStyle == null)
                      ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      : settingsGroupTitleStyle,
                ),
              )
            : Container(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(height: 1, color: Theme.of(context).focusColor,);
              },
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return items[index];
              },
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}