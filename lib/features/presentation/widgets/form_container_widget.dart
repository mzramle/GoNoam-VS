import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final bool enabled;
  final bool showError;
  final String? fieldName;
  final ValueChanged<String>? onChanged;

  const FormContainerWidget({
    super.key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
    this.enabled = true,
    this.showError = false,
    this.fieldName,
    this.onChanged,
  });

  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.fieldName != null)
          Text(
            widget.fieldName!,
            style: const TextStyle(color: Color(0xFF4E0189), fontSize: 16),
          ),
        if (widget.fieldName != null) const SizedBox(height: 5),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            style: const TextStyle(color: Colors.black),
            controller: widget.controller,
            keyboardType: widget.inputType,
            key: widget.fieldKey,
            obscureText: widget.isPasswordField == true ? _obscureText : false,
            onSaved: widget.onSaved,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black45),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.showError ? Colors.red : Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.showError ? Colors.red : Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: widget.isPasswordField == true
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color:
                            _obscureText == false ? Colors.blue : Colors.grey,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (widget.showError)
          const Text(
            'Passwords do not match',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}
