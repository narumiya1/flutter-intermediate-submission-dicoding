import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/login_request_m.dart';
import 'package:submission_intermediate/data/pref/token.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';
import 'package:submission_intermediate/provider/login_p.dart';
import 'package:submission_intermediate/utils/helpers.dart';
import 'package:submission_intermediate/utils/show_snackbar.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegisterClicked;

  const LoginPage(
      {super.key,
      required this.onLoginSuccess,
      required this.onRegisterClicked});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<LoginProvider>(
        create: (context) => LoginProvider(ApiService(), Token()),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            child: Center(
              child: Column(
                children: [
                  Text('Login Page'),
                  SizedBox(height: 14),
                  SvgPicture.asset(
                    'assets/user.svg',
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(height: 14),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Plase enter your email!';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(hintText: "Email"),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Plase enter your password!';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration:
                              const InputDecoration(hintText: "Password"),
                        ),

                        const SizedBox(height: 8),

                        Consumer<LoginProvider>(
                          builder: (context, provider, _) {
                            _handleStateStatus(context,provider);

                            return ElevatedButton(
                              onPressed: () => {
                                if (_formKey.currentState?.validate() == true)
                                  {
                                    provider.loginP(
                                      LoginRequest(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    ),
                                  }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (provider.loginState ==
                                      ResultState.loading) ...[
                                    const SizedBox(
                                      width: 40 * 0.5,
                                      height: 40 * 0.5,
                                      child: CircularProgressIndicator(),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  const Text('Login')
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => widget.onRegisterClicked(),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _handleStateStatus(BuildContext context, provider) {
    switch (provider.loginState) {
      case ResultState.hasData:
        afterBuildWidgetCallback(widget.onLoginSuccess);
        // showSnackBar(provider.loginMessage);
      Future.delayed(const Duration(microseconds: 200), () =>
          showSnackBar(context, provider.loginMessage));
        break;
      case ResultState.noData:
       Future.delayed(const Duration(microseconds: 200), () =>
          showSnackBar(context, provider.loginMessage));
        
        break;
      case ResultState.error:
      Future.delayed(const Duration(microseconds: 200), () =>
          showSnackBar(context, provider.loginMessage));

        break;
      default:
        break;
    }
  }
}
