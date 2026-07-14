import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/dbaas/db_user_registry_manager.dart';
import 'package:tutor_server/src/trace/trc_comp.dart';

/// The user authenticator class.
class UserAuthenticator {
  /// A reference to the database connection instance.
  static final DbUserRegistryManager _dbURM = DbUserRegistryManager();

  /// Component logger for logging user authentication related events.
  static final ComponentTrace trace = ComponentTrace();

  /* TO-DO In a real application, 
    - you would want to use a secure secret key and an appropriate signing 
      algorithm instead of a hardcoded value like '123'.
    - you would want to be sure to correctly store it and pass it to the code
      in a way where then will remain secret to outsiders.
    */
  /// Secret key for signing JWT tokens.
  static const String _secretKey = '123';

  /// Server full name
  static const String _issuerName = 'English Tutor Server';

  /// Token validity duration
  static const Duration _tokenExpiry = Duration(hours: 2);

  /// Token expiry duration in seconds (for client-side use)
  int get tokenExpiry => _tokenExpiry.inSeconds;

  /// Authenticates a user by their username and password.
  Future<String?> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      return await _dbURM.validateUsernameAndPassword(
        username: username,
        password: password,
      );
    } on NetworkException catch (e) {
      trace.error('DBaaS network error: $e.', name: '0x01');
      rethrow;
    } on DatabaseException catch (e) {
      trace.error('DBaaS databse error: $e.', name: '0x02');
      rethrow;    
    } catch (e) {
      trace.error('DBaaS database server error: $e.', name: '0x03');
      rethrow;
    }
  }

  /// Generates a JWT authentication token for a given user.
  String generateToken({required String userid}) {
    final jwt = JWT({'userid': userid}, issuer: _issuerName);
    final token = jwt.sign(SecretKey(_secretKey), expiresIn: _tokenExpiry);
    return token;
  }

  /// Verifies a token and returns the corresponding user if the token is valid
  String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final payload = jwt.payload as Map<String, dynamic>;
      return payload['userid'] as String;
    } on JWTExpiredException catch (e) {
      trace.info('Token has expired: $e.', name: '0x04', assoc: token);
      return null;
    } on JWTException catch (e) {
      trace.info('Invalid token: $e.', name: '0x05', assoc: token);
      return null;
    } catch (e) {
      return null;
    }
  }
}
