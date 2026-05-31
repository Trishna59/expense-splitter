import 'package:flutter/material.dart';
import 'package:Expenses_splitter/feature/auth/presentation/widgets/auth_field.dart';
import 'package:Expenses_splitter/feature/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:Expenses_splitter/feature/auth/presentation/domain/data/auth_method.dart';
import 'package:Expenses_splitter/feature/auth/presentation/pages/signup_page.dart';
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInUser() async {
    setState(() => _isLoading = true);

    String res = await AuthMethod().signInUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);
    if (res == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Sign In',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              AuthField(
                hintText: 'Email',
                controller: _emailController,
                isPassword: false,
              ),
              const SizedBox(height: 15),
              AuthField(
                hintText: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : AuthGradientButton(
                      buttonText: 'Sign In',
                      onPressed: _signInUser,
                    ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(color: Colors.white60, fontSize: 16),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}