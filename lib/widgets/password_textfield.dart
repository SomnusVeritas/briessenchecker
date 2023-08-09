import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField(
      {super.key, required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscured = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: isObscured,
      autofillHints: const ['password', 'pass', 'login'],
      onFieldSubmitted: (value) => widget.onSubmitted(),
      decoration: InputDecoration(
        label: const Text('Password'),
        suffixIcon: TextButton(
          onPressed: () => setState(() => isObscured = !isObscured),
          child: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
