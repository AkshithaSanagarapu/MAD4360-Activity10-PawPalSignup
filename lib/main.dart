import 'package:flutter/material.dart';

void main() {
  runApp(const PawPalApp());
}

const Map<String, List<String>> localSignupTips = {
  'password_help': [
    'Try a passphrase made from several unrelated words. It is easier to remember and harder to guess.',
    'Use a password you have not used on another account.',
    'A longer password is usually easier to remember when it is a short phrase.',
  ],
};

class PawPalApp extends StatelessWidget {
  const PawPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6B4EFF);

    return MaterialApp(
      title: 'PawPal Signup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: seedColor,
          secondary: const Color(0xFF19A88A),
          surface: const Color(0xFFF8F7FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCD8EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seedColor, width: 2),
          ),
        ),
      ),
      home: const SignupPage(),
    );
  }
}

enum TipState { idle, loading, ready, error }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  TipState _tipState = TipState.idle;
  String? _tipText;
  int _tipIndex = -1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getSignupTip() async {
    setState(() {
      _tipState = TipState.loading;
      _tipText = null;
    });

    // A short local delay shows loading. No network request is made.
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    const category = 'password_help';
    final tips = localSignupTips[category];

    if (tips == null || tips.isEmpty) {
      setState(() {
        _tipState = TipState.error;
        _tipText = null;
      });
      return;
    }

    final nextTipIndex = (_tipIndex + 1) % tips.length;
    final selectedTip = tips[nextTipIndex];
    if (selectedTip.length > 240) {
      setState(() {
        _tipState = TipState.error;
        _tipText = null;
      });
      return;
    }

    setState(() {
      _tipIndex = nextTipIndex;
      _tipState = TipState.ready;
      _tipText = selectedTip;
    });
  }

  void _submitForm() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final name = _nameController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WelcomePage(name: name),
      ),
    );
  }

  Widget _buildTipPanel() {
    Widget content;
    final tips = localSignupTips['password_help'] ?? const <String>[];

    switch (_tipState) {
      case TipState.idle:
        content = const Text(
          'Tap below to read a password tip stored in the app.',
        );
        break;
      case TipState.loading:
        content = const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Finding a local tip…')),
          ],
        );
        break;
      case TipState.ready:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tip ${_tipIndex + 1} of ${tips.length}',
              style: const TextStyle(
                color: Color(0xFF6B4EFF),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(_tipText ?? ''),
          ],
        );
        break;
      case TipState.error:
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'No preset tip is available right now. Check the local tip list, then retry.',
              ),
            ),
            TextButton(
              onPressed: _getSignupTip,
              child: const Text('Retry'),
            ),
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DFFC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF6B4EFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preset tip — local sample, not live AI output',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _tipState == TipState.loading ? null : _getSignupTip,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                _tipState == TipState.loading
                    ? 'Getting tip…'
                    : _tipState == TipState.ready
                        ? 'Get another signup tip'
                        : 'Get a signup tip',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal • Join the pack'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B4EFF), Color(0xFF947EFF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.pets, color: Colors.white, size: 34),
                          SizedBox(height: 12),
                          Text(
                            'Find your people. Help more pets.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create your PawPal account to join local adoption events.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Please enter your email.';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Please enter an email address in a valid format.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        helperText: 'Use at least 6 characters.',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'The passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTipPanel(),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.pets),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your form is validated on this device. No account is created or stored.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PawPal')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 76, color: Color(0xFF19A88A)),
              const SizedBox(height: 18),
              Text(
                'Welcome, ' + name + '!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your signup form passed validation. No account was created or saved.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

