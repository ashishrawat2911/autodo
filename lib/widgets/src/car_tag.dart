import 'package:flutter/material.dart';

class CarTag extends StatelessWidget {
  const CarTag({Key key, @required this.text, this.color = Colors.blue})
      : super(key: key);

  final String text;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme.fromButtonThemeData(
      data: ButtonThemeData(
        minWidth: 0,
        padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      ),
      child: FlatButton(
        child: Chip(
          backgroundColor: color,
          label: Text(
            text,
            style: Theme.of(context).accentTextTheme.bodyText1,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
