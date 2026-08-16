import 'models.dart';

class ValidationResult {
  final bool isValid;
  final String? rejectReason;

  const ValidationResult.ok()
      : isValid = true,
        rejectReason = null;

  const ValidationResult.reject(this.rejectReason) : isValid = false;
}

class FixValidator {
  const FixValidator();

  ValidationResult validate(RawFix fix, RawFix? previousFix) {
    if (fix.lat < -90 || fix.lat > 90 || fix.lng < -180 || fix.lng > 180) {
      return const ValidationResult.reject('invalid_coordinate');
    }

    if (previousFix != null && fix.timestamp.compareTo(previousFix.timestamp) <= 0) {
      return const ValidationResult.reject('invalid_timestamp');
    }

    // A mocked fix isn't necessarily rejected for all use cases, 
    // but in this pipeline we reject it by default to avoid ghost traces.
    if (fix.isMocked) {
      return const ValidationResult.reject('mocked_fix');
    }

    return const ValidationResult.ok();
  }
}
