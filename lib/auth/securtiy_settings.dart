import 'package:flutter/material.dart';

import 'biometric_pref.dart';
import 'biometric_service.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key});

  @override
  State<SecuritySettings> createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _enabled = await BiometricPref.isEnabled();
    setState(() {});
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final success = await BiometricService().authenticate();
      if (!success) return;
      await BiometricPref.enable();
    } else {
      await BiometricPref.disable();
    }
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Fingerprint Lock'),
      subtitle: const Text('Use fingerprint to unlock app'),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}
