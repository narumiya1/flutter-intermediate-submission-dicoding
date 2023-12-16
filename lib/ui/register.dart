import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/register_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';
import 'package:submission_intermediate/provider/register_p.dart';
import 'package:submission_intermediate/utils/helpers.dart';

class Registerpage extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const Registerpage({super.key, required this.onRegisterSuccess});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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
        body: ChangeNotifierProvider<RegisterProvider>(
      create: (context) => RegisterProvider(ApiService()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          
            children: [
              Column(
                children: [
                  Text(
                    'Register',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Plase enter your name!';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "Name"),
                    ),
                    const SizedBox(height: 8),
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
                      decoration: const InputDecoration(hintText: "Password"),
                    ),
                    const SizedBox(height: 16),
                    Consumer<RegisterProvider>(
                      builder: (context, provider, _) {
                        _handleState(provider);

                        return ElevatedButton(
                          onPressed: () => {
                            if (_formKey.currentState?.validate() == true)
                              {
                                provider.register(
                                  RegisterRequest(
                                    name: _nameController.text,
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
                              if (provider.registerState ==
                                  ResultState.loading) ...[
                                const SizedBox(
                                  width: 40 * 0.5,
                                  height: 40 * 0.5,
                                  child: CircularProgressIndicator(),
                                ),
                                const SizedBox(width: 8),
                              ],
                              const Text('Register')
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
        
        ),
      ),
    ));
  }

   _handleState(RegisterProvider provider) {
    switch (provider.registerState) {
      case ResultState.hasData:
        afterBuildWidgetCallback(() => widget.onRegisterSuccess());
        // showToast(provider.registerMessage);
        break;
      case ResultState.noData:
      case ResultState.error:
        // showToast(provider.registerMessage);
        break;
      default:
        break;
    }
  }
}
