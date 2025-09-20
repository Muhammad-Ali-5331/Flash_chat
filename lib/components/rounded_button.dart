import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color clr;
  final String text;
  final VoidCallback? onPress;
  const RoundedButton(this.clr, this.text, this.onPress, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: clr,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(text),
        ),
      ),
    );
  }
}
