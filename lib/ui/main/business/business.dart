import 'package:flutter/material.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'Business',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
