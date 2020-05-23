import 'package:flutter/material.dart';

class BButton extends StatelessWidget {
  BButton({this.child, this.onTap});
  final Widget child;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: this.child,
      onTap: this.onTap,
    );
  }
}
