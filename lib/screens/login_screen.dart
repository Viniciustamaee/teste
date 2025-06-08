import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function(String email, String senha, bool isLogin) onSubmit;

  const LoginScreen({super.key, required this.onSubmit});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _senha = '';

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.save();
    widget.onSubmit(_email.trim(), _senha.trim(), _isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const ValueKey('email'),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Informe um e-mail válido.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              TextFormField(
                key: const ValueKey('senha'),
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Senha precisa ter ao menos 6 caracteres.';
                  }
                  return null;
                },
                onSaved: (value) => _senha = value ?? '',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _trySubmit,
                child: Text(_isLogin ? 'Entrar' : 'Cadastrar'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Criar nova conta' : 'Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}