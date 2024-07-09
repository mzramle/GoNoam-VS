import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSliderZeroToOneWidget extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double? divisions;
  final double increment;
  final ValueChanged<double> onChanged;

  const CustomSliderZeroToOneWidget({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.increment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label: $value',
          style: GoogleFonts.robotoCondensed(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        Slider(
          // label: value.toString(),
          activeColor: Colors.blue,
          inactiveColor: Colors.blueGrey,
          thumbColor: Colors.deepOrange,
          label: label,
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / increment).round(),
          onChanged: (newValue) {
            newValue = (newValue / increment).round() * increment;
            onChanged(newValue);
          },
        ),
      ],
    );
  }
}
