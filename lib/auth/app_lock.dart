import 'package:flutter/material.dart';
import 'biometric_pref.dart';
import 'biometric_service.dart';

class AppLock extends StatefulWidget {
  final Widget child;
  const AppLock({super.key, required this.child});

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();

  bool _isAuthenticated = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateUser();
    });
  }

  Future<void> _authenticateUser() async {
    try {
      final enabled = await BiometricPref.isEnabled();

      if (!enabled) {
        setState(() {
          _isAuthenticated = true;
          _checking = false;
        });
        return;
      }

      final success = await _biometricService.authenticate();

      setState(() {
        _isAuthenticated = success;
        _checking = false;
      });
    } catch (e) {
      // 🔒 Fail-safe: never lock user out completely
      setState(() {
        _isAuthenticated = true;
        _checking = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateUser();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Unlock with fingerprint',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _authenticateUser,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
