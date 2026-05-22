import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';

class ResendVerificationScreen extends ConsumerStatefulWidget {
  const ResendVerificationScreen({super.key});

  @override
  ConsumerState<ResendVerificationScreen> createState() => _ResendVerificationScreenState();
}

class _ResendVerificationScreenState extends ConsumerState<ResendVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe8f0f7), Color(0xFFf5f7fa)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isLargeScreen
                ? _buildWideLayout(context, authState, authNotifier)
                : _buildMobileLayout(context, authState, authNotifier),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, AuthState authState, AuthNotifier authNotifier) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text("Resend Verification", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text("Didn't receive the email? We'll send you a new verification link.",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: _buildForm(context, authState, authNotifier, withPadding: true)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthState authState, AuthNotifier authNotifier) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            Icon(Icons.email_outlined, color: Theme.of(context).primaryColor, size: 70),
            const SizedBox(height: 16),
            const Text("Resend Verification Email", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildForm(context, authState, authNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthState authState, AuthNotifier authNotifier, {bool withPadding = false}) {
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          if (withPadding) const SizedBox(height: 20),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your registered email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v!.contains('@') ? null : 'Please enter a valid email',
          ),

          const SizedBox(height: 32),

          if (authState.isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authNotifier.resendVerification(_emailController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Resend Verification Email'),
              ),
            ),

          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
            ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/signin'),
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );

    return withPadding
        ? Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: form)
        : form;
  }
}