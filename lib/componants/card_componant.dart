import 'package:flutter/material.dart';
import 'package:sensorflutterapp/colors.dart';

class CardComponant extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  const CardComponant({super.key,
  required this.label,
  required this.value,
  required this.unit
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: appColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 18,color: textColor),),
            const SizedBox(height: 10),
            Text('$value $unit', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: textColor)),
          ],
        ),
      ),
    );
  }
}