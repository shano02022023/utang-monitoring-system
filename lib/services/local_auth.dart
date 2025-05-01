import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class LocalAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      // If no biometric setup, automatically authenticate the user
      if (!canCheckBiometrics || availableBiometrics.isEmpty) {
        print('Biometrics not available or not set up. Skipping auth.');
        return true; // <-- Allow user in
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate using Face ID or Fingerprint',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Sign in',
            cancelButton: 'Cancel',
            biometricHint: 'Use Face ID or Fingerprint to authenticate',
          ),
        ],
      );
    } catch (e) {
      print('Error authenticating with biometrics: ${e.toString()}');
      return true; // <-- Still allow in on error
    }
  }
}
