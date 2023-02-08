import 'package:flutter/material.dart';

class NameIcon extends StatelessWidget {
  final String firstName;
  final Color backgroundColor;
  final Color textColor;

   const NameIcon(
      {Key? key, required this.firstName, this.backgroundColor= Colors.white, this.textColor= Colors.black,}) : super(key: key);

  String get firstLetter => firstName.substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        padding: const EdgeInsets.all(120.0),
        child: Text(firstLetter, style: TextStyle(color: textColor, fontSize: 200, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
