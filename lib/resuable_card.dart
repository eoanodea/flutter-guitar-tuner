import 'package:flutter/material.dart';

class ReuseableCard extends StatelessWidget {
  const ReuseableCard(
      {Key? key,
      required this.colour,
      required this.cardChild,
      required this.onPress})
      : super(key: key);

  final Color colour;
  final Widget cardChild;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPress(),
      child: Container(
        child: cardChild,
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
