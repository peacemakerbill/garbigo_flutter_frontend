import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _hasAttemptedVerification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyEmail();
    });
  }

  Future<void> _verifyEmail() async {
    if (_hasAttemptedVerification || widget.token.isEmpty) return;
    setState(() => _hasAttemptedVerification = true);

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.verifyEmail(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    // Auto redirect after successful verification
    if (authState.verified && !authState.isLoading && authState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/signin');
      });
    }

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

  Widget _buildWideLayout(BuildContext context, AuthState authState) {
    final isError = authState.error != null;

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
                color: isError ? const Color(0xFFc0392b) : Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.mark_email_read,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isError ? "Verification Failed" : "Email Verification",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isError
                          ? "Something went wrong while verifying your email."
                          : "We are verifying your email address. This only takes a moment.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: _buildContent(context, authState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthState authState) {
    final isError = authState.error != null;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red.shade50
                    : Theme.of(context).primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.mark_email_read,
                color: isError ? Colors.red.shade400 : Theme.of(context).primaryColor,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isError ? "Verification Failed" : "Email Verification",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a2e),
              ),
            ),
            const SizedBox(height: 32),
            _buildContent(context, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState authState) {
    if (authState.isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          const Text(
            "Verifying your email...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      );
    }

    if (authState.error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade400, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "The verification link may have expired or already been used. "
                "Please request a new one from the sign in page.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/signin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/resend-verification'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Resend Verification Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    // Success state
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Email Verified Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your account is now active. Redirecting you to sign in...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/signin'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Go to Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}