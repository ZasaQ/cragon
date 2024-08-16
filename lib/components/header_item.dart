import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HeaderItem extends StatelessWidget {
  final IconData headerIcon;
  final double? headerIconSize;
  final String headerText;
  final EdgeInsets? headerPadding;

  const HeaderItem({
    super.key,
    required this.headerIcon,
    this.headerIconSize,
    required this.headerText,
    this.headerPadding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: headerPadding ?? const EdgeInsets.only(bottom: 60, top: 20),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Icon(headerIcon, size: headerIconSize ?? 100.0),
          ),
      
          Align(
            alignment: Alignment.center,
            child: Text(
              headerText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}