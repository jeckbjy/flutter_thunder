import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Button({
    @required this.child, 
    @required this.onPressed,
    this.padding = const EdgeInsets.all(4)
  });

  final Widget child;
  final GestureTapCallback onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: padding,
        child: child,
      )
    );
  }
}