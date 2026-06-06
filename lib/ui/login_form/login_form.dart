import 'package:flutter/material.dart';
import 'package:tomza_kit/ui/components/input/form_header.dart';
import 'package:tomza_kit/ui/components/input/tomza_user_input.dart';
import 'package:tomza_kit/ui/components/shake_change.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.header,
    required this.userController,
    required this.passwordController,
    required this.shakeTick,
    this.isLoginLoading = false,
    this.isPasswordVisible = false,
    this.spacing = 24.0,
  });

  final String header;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool isLoginLoading;
  final bool isPasswordVisible;
  final int shakeTick;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ShakeOnChange(
      tick: shakeTick,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header.isNotEmpty) ...[
            FormHeader(title: header),
            SizedBox(height: spacing),
          ],
          UserInput(
            title: '',
            controller: userController,
            label: 'Usuario',
            hint: 'Ingrese su usuario',
            prefixIcon: const Icon(Icons.person),
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: spacing),
          UserInput(
            title: '',
            controller: passwordController,
            label: 'Contraseña',
            hint: 'Ingrese su contraseña',
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
