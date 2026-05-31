import 'package:flutter/material.dart';
import 'package:Expenses_splitter/feature/auth/presentation/pages/signin_page.dart';
import 'package:Expenses_splitter/feature/auth/presentation/pages/verify_email_page.dart';
import 'package:Expenses_splitter/feature/auth/presentation/widgets/auth_field.dart';
import 'package:Expenses_splitter/feature/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:Expenses_splitter/feature/auth/presentation/domain/data/auth_method.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUpUser() async {
    setState(() => _isLoading = true);

    String res = await AuthMethod().signUpUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res == 'success') {
      if (!mounted) return;
     Navigator.pushReplacement(
    context,
     MaterialPageRoute(builder: (context) => const VerifyEmailPage()),
     );
    
      // Navigate to sign in after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
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
                'Sign Up',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              AuthField(
                hintText: 'Name',
                controller: _nameController,
                isPassword: false,
              ),
              const SizedBox(height: 15),
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
                      buttonText: 'Sign Up',
                      onPressed: _signUpUser,
                    ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.white60, fontSize: 16),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
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