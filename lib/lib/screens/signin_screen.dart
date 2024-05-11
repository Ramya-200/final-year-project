import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/components/auth_state.dart';
import '/utils/helpers.dart';
import '/utils/constants.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends AuthState<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _signInEmailController =
      RoundedLoadingButtonController();

  String _email = '';
  String _password = '';

  @override
  void onErrorAuthenticating(String message) {
    showMessage(message);
  }

  Future _onSignInPress(BuildContext context) async {
    final form = formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      final response = await Supabase.instance.client.auth
          .signIn(email: _email, password: _password);
      if (response.error != null) {
        showMessage(response.error!.message);
        _signInEmailController.reset();
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } else {
      _signInEmailController.reset();
    }
  }

  void showMessage(String message) {
    if (message == "Failed host lookup: '$supabaseUrl'") {
      message = 'Please check your internet connection';
    }
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Student Details'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 35.0),
              Image.asset('assets/images/logo.png', width: 100, height: 100),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 80.0),
              TextFormField(
                onSaved: (value) => _email = value ?? '',
                validator: (val) => validateEmail(val),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: '',
                  prefixIcon: Icon(Icons.mail_outline),
                  label: Text('Email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _password = value ?? '',
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '',
                  label: Text('Password'),
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
               RoundedLoadingButton(
                color: Colors.green,
                controller: _signInEmailController,
                onPressed: () {
                  _onSignInPress(context);
                },
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15.0),
              TextButton(
                onPressed: () {
                  stopAuthObserver();
                  Navigator.pushNamed(context, '/forgotPassword')
                      .then((_) => startAuthObserver());
                },
                child: const Text("Forgot your password ?"),
              ),
              TextButton(
                onPressed: () {
                  stopAuthObserver();
                  Navigator.pushNamed(context, '/signUp')
                      .then((_) => startAuthObserver());
                },
                child: const Text("Don’t have an Account ? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
