import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSliderWidget extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const CustomSliderWidget({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
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
          activeColor: Colors.blue,
          inactiveColor: Colors.blueGrey,
          thumbColor: Colors.deepOrange,
          label: label,
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
