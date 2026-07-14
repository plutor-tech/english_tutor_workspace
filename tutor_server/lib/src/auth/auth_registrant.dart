import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/dbaas/db_user_registry_manager.dart';
import 'package:tutor_server/src/trace/trc_comp.dart';

/// Username value validity check.
extension _UsernameValidityCheck on String {
  /// String extension for username value validity check.
  bool get isValidUsername => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
}

/// Password value validity check.
extension _PasswordValidityCheck on String {
  /// String extension for password value validity check.
  bool get isValidPassword => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
}

/// The registrant class that manages user registrations.
class UserRegistrant {
  /// A reference to the database connection instance.
  static final DbUserRegistryManager _dbURM = DbUserRegistryManager();

  /// Component logger for logging user registration related events.
  static final ComponentTrace trace = ComponentTrace();

  /// Registers a new user with the given username and password. Returns the
  /// userid generated for the user if registration is successful, otherwise
  /// returns null.
  Future<String?> registerUser({
    required String? username,
    required String? password,
  }) async {
    // Check input validity
    if (username == null || !username.isValidUsername) {
      const errMessage = 'Invalid value for username.';
      throw const ValidationException(errMessage, ValExpField.username);
    }
    if (password == null || !password.isValidPassword) {
      const errMessage = 'Invalid value for password.';
      throw const ValidationException(errMessage, ValExpField.password);
    }

    try {
      final userid = await _dbURM.addNewRecord(
        username: username,
        password: password,
      );
      return userid;
    } on NetworkException catch (e) {
      trace.error('DBaaS network error: $e.', name: '0x01');
      rethrow;
    } on DatabaseException catch (e) {
      trace.error('DBaaS database error: $e.', name: '0x02');
      rethrow;
    } catch (e) {
      trace.error('DBaaS database operational error: $e.', name: '0x03');
      rethrow;
    }
  }
}
