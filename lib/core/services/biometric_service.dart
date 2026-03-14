import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Returns true on success, false if the user cancelled.
  /// Throws [BiometricException] for unrecoverable errors.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access SpendWise',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricHardware:
          throw BiometricException('This device has no biometric hardware.');
        case LocalAuthExceptionCode.biometricLockout:
        case LocalAuthExceptionCode.temporaryLockout:
          throw BiometricException(
            'Too many failed attempts. '
            'Please unlock your device with your PIN first.',
          );
        default:
          // Covers user cancellation and any other codes
          return false;
      }
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}

class BiometricException implements Exception {
  final String message;
  const BiometricException(this.message);
  @override
  String toString() => message;
}
