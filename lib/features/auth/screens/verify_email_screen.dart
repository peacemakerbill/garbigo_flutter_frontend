import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerWidget {
  final String token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authState.isLoading) {
        authNotifier.verifyEmail(token);
      }
    });

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
                ? _buildWideLayout(context, authState)
                : _buildMobileLayout(context, authState),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, authState) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text(
                      "Email Verification",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "We're verifying your email address to ensure "
                          "the security of your account and enable all features.",
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildContent(context, authState, withPadding: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, authState) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              authState.error != null ? Icons.error_outline : Icons.mark_email_read,
              color: authState.error != null ? Colors.red : Theme.of(context).primaryColor,
              size: 70,
            ),
            const SizedBox(height: 16),
            Text(
              authState.error != null ? "Verification Failed" : "Email Verification",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildContent(context, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, authState, {bool withPadding = false}) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (withPadding) const SizedBox(height: 20),

        if (authState.isLoading)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                "Verifying your email...",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          )
        else if (authState.error != null)
          Column(
            children: [
              const Text(
                'Verification failed',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                authState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/signin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Sign In'),
              ),
            ],
          )
        else
          Column(
            children: [
              const Text(
                'Email Verified Successfully!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your email has been verified. You can now access all features of your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/signin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
      ],
    );

    return withPadding
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(child: content),
    )
        : content;
  }
}