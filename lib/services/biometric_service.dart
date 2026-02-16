import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Result of a biometric authentication attempt.
enum BiometricAuthResult {
  success,
  cancelled,
  notAvailable,
  failure,
}

/// Service for fingerprint / biometric authentication.
/// Uses [local_auth]; no-op on web.
/// The prompt is 100% local (device) — backend (inifinityCageX) is only used after success, to login with saved credentials.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// True if we're on a platform that supports local_auth (not web).
  bool get isSupportedPlatform => !kIsWeb;

  /// Whether the device can use biometrics (fingerprint, face, etc.).
  Future<bool> canCheckBiometrics() async {
    if (!isSupportedPlatform) return false;
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Whether device has at least one biometric enrolled and plugin is available.
  Future<bool> isDeviceSupported() async {
    if (!isSupportedPlatform) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric types (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!isSupportedPlatform) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Returns true if fingerprint or face is available and enrolled.
  Future<bool> hasBiometricEnrolled() async {
    if (!isSupportedPlatform) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final list = await _auth.getAvailableBiometrics();
      return list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate with biometric (or device PIN/passcode if allowed).
  /// [reason] is shown in the system dialog (e.g. "Sign in to Infinity Cage").
  /// [biometricOnly] if true, does not fall back to device credentials.
  /// Returns [BiometricAuthResult] so UI can show the right message (e.g. don't show error on cancel).
  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    if (!isSupportedPlatform) return BiometricAuthResult.notAvailable;
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricAuthResult.success : BiometricAuthResult.cancelled;
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          return BiometricAuthResult.cancelled;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.noCredentialsSet:
          return BiometricAuthResult.notAvailable;
        case LocalAuthExceptionCode.uiUnavailable:
        case LocalAuthExceptionCode.authInProgress:
        case LocalAuthExceptionCode.timeout:
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        default:
          return BiometricAuthResult.failure;
      }
    } catch (_) {
      return BiometricAuthResult.failure;
    }
  }
}
