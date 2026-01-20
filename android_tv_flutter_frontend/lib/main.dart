import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

/// Top-level app widget that sets up routes for Login and Home.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      // TV-friendly: slightly larger text by default.
      textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.15),
    );

    return MaterialApp(
      title: 'AI Build Tool',
      theme: theme,
      // Boot to Login.
      initialRoute: LoginScreen.routeName,
      routes: <String, WidgetBuilder>{
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}

/// Intent to trigger "select/activate" via DPAD_CENTER/ENTER/SPACE.
class ActivateIntent extends Intent {
  const ActivateIntent();
}

/// A thin wrapper around a focusable widget that:
/// - shows a highlight when focused
/// - triggers `onActivate` on DPAD_CENTER/ENTER/SPACE
class TvFocusable extends StatelessWidget {
  const TvFocusable({
    super.key,
    required this.focusNode,
    required this.child,
    this.onActivate,
    this.autofocus = false,
  });

  final FocusNode focusNode;
  final Widget child;
  final VoidCallback? onActivate;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // FocusableActionDetector no longer supports a `builder` parameter in the
    // Flutter version used by this project. Instead, we track focus changes and
    // rebuild the highlight UI accordingly.
    final ValueNotifier<bool> hasFocus = ValueNotifier<bool>(focusNode.hasFocus);

    return FocusableActionDetector(
      focusNode: focusNode,
      autofocus: autofocus,
      onShowFocusHighlight: (bool value) => hasFocus.value = value,
      onFocusChange: (bool value) => hasFocus.value = value,
      shortcuts: const <ShortcutActivator, Intent>{
        // Android TV DPAD_CENTER is typically sent as "select"/enter on Flutter;
        // support both Enter and Select for robustness.
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            onActivate?.call();
            return null;
          },
        ),
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: hasFocus,
        builder: (BuildContext context, bool focused, Widget? _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 3,
                color: focused
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              boxShadow: focused
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(90),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  // Focus nodes for DPAD navigation.
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _loginButtonFocus;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _usernameFocus = FocusNode(debugLabel: 'username');
    _passwordFocus = FocusNode(debugLabel: 'password');
    _loginButtonFocus = FocusNode(debugLabel: 'loginButton');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _loginButtonFocus.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // Overscan-safe padding: keep UI away from edges.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 28),

                    // Username field (DPAD focusable).
                    TvFocusable(
                      focusNode: _usernameFocus,
                      autofocus: true,
                      onActivate: () {
                        // On TV, "activate" on the field should allow editing.
                        // Request focus triggers caret/keyboard behavior as available.
                        _usernameFocus.requestFocus();
                      },
                      child: TextField(
                        focusNode: _usernameFocus,
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter username',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                        ),
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Password field (DPAD focusable).
                    TvFocusable(
                      focusNode: _passwordFocus,
                      onActivate: () => _passwordFocus.requestFocus(),
                      child: TextField(
                        focusNode: _passwordFocus,
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                        ),
                        onSubmitted: (_) => _loginButtonFocus.requestFocus(),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Login button (DPAD focusable; DPAD_CENTER triggers).
                    TvFocusable(
                      focusNode: _loginButtonFocus,
                      onActivate: _goHome,
                      child: SizedBox(
                        height: 64,
                        child: ElevatedButton(
                          focusNode: _loginButtonFocus,
                          onPressed: _goHome,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Use the DPAD to move focus. Press DPAD_CENTER/Enter to activate.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(170),
                          ),
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

/// Placeholder Home screen (TV-friendly). Existing route name: '/home'.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text(
            'Home Screen\n\n(Placeholder)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
