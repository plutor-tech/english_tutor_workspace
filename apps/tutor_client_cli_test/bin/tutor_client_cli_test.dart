import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 
  'https://tutor-server-backend-117837570613.us-central1.run.app';
  //'http://localhost:8080';
String? authToken;

void main() async {
  print('========================================');
  print('   English Tutor Server Request Tester  ');
  print('========================================');

  while (true) {
    print('\n---------------- MENU ----------------');
    print('1. Register Native (POST /usr/auth/register_native)');
    print('2. Sign In Native   (POST /usr/auth/sign_in/native)');
    print('3. GET Reqs         (GET  /usr/reqs)');
    print('4. POST Reqs        (POST /usr/reqs)');
    print('5. View / Edit Token (Current: ${authToken != null ? "${authToken!.substring(0, authToken!.length > 15 ? 15 : authToken!.length)}..." : "None"})');
    print('6. Exit');
    stdout.write('Select an option (1-6): ');

    final input = stdin.readLineSync()?.trim();

    switch (input) {
      case '1':
        await registerNative();
        break;
      case '2':
        await signInNative();
        break;
      case '3':
        await getReqs();
        break;
      case '4':
        await postReqs();
        break;
      case '5':
        manageToken();
        break;
      case '6':
        print('\nExiting application.');
        exit(0);
      default:
        print('\n[!] Invalid choice. Please enter a number between 1 and 6.');
    }
  }
}

/// 1. Register Native User
Future<void> registerNative() async {
  final username = promptInput('Username', defaultValue: 'vut2');
  final password = promptInput('Password', defaultValue: '123');

  final url = Uri.parse('$baseUrl/usr/auth/register_native');
  final body = jsonEncode({'username': username, 'password': password});

  print('\n[Sending POST to $url]');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    printFormattedResponse(response);
  } catch (e) {
    print('\n[!] Request Failed: $e');
  }
}

/// 2. Sign In Native & Capture Bearer Token
Future<void> signInNative() async {
  final username = promptInput('Username', defaultValue: 'vut2');
  final password = promptInput('Password', defaultValue: '123');

  final url = Uri.parse('$baseUrl/usr/auth/sign_in/native');
  final body = jsonEncode({'username': username, 'password': password});

  print('\n[Sending POST to $url]');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    printFormattedResponse(response);

    // Extract token if request succeeded
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('token')) {
          authToken = data['token'].toString();
        } else if (data is Map && data.containsKey('token_id')) {
          authToken = data['token_id'].toString();
        } else {
          // If response body is directly the token string
          authToken = response.body.trim().replaceAll('"', '');
        }
        print('[✓] Token automatically captured and saved.');
      } catch (_) {
        // If body is plain text token
        if (response.body.isNotEmpty) {
          authToken = response.body.trim();
          print('[✓] Token automatically captured from response body.');
        }
      }
    }
  } catch (e) {
    print('\n[!] Request Failed: $e');
  }
}

/// 3. GET Protected Requests
Future<void> getReqs() async {
  if (authToken == null) {
    print('\n[!] Warning: No auth token stored.');
    stdout.write('Proceed anyway? (y/n): ');
    final ans = stdin.readLineSync()?.trim().toLowerCase();
    if (ans != 'y') return;
  }

  final url = Uri.parse('$baseUrl/usr/reqs');
  final headers = <String, String>{};
  if (authToken != null) {
    headers['Authorization'] = 'Bearer $authToken';
  }

  print('\n[Sending GET to $url]');
  try {
    final response = await http.get(url, headers: headers);
    printFormattedResponse(response);
  } catch (e) {
    print('\n[!] Request Failed: $e');
  }
}

/// 4. POST Protected Request
Future<void> postReqs() async {
  if (authToken == null) {
    print('\n[!] Warning: No auth token stored.');
    stdout.write('Proceed anyway? (y/n): ');
    final ans = stdin.readLineSync()?.trim().toLowerCase();
    if (ans != 'y') return;
  }

  final bodyText = promptInput('Request Payload String', defaultValue: 'Buy bread');

  final url = Uri.parse('$baseUrl/usr/reqs');
  final headers = <String, String>{};
  if (authToken != null) {
    headers['Authorization'] = 'Bearer $authToken';
  }

  print('\n[Sending POST to $url]');
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: bodyText,
    );
    printFormattedResponse(response);
  } catch (e) {
    print('\n[!] Request Failed: $e');
  }
}

/// 5. View/Edit Stored Token Manually
void manageToken() {
  print('\nCurrent Token: ${authToken ?? "None"}');
  stdout.write('Enter new token (or press Enter to keep current): ');
  final input = stdin.readLineSync()?.trim();
  if (input != null && input.isNotEmpty) {
    authToken = input;
    print('[✓] Token updated.');
  }
}

/// Helper: Prompts CLI input with fallback defaults
String promptInput(String prompt, {required String defaultValue}) {
  stdout.write('$prompt [$defaultValue]: ');
  final input = stdin.readLineSync()?.trim();
  return (input == null || input.isEmpty) ? defaultValue : input;
}

/// Helper: Formats and displays HTTP response clearly
void printFormattedResponse(http.Response response) {
  print('\n================ HTTP RESPONSE ================');
  print('Status  : ${response.statusCode} ${response.reasonPhrase}');
  print('Headers :');
  response.headers.forEach((key, value) {
    print('  $key: $value');
  });
  print('\nBody:');

  final bodyStr = response.body.trim();
  if (bodyStr.isEmpty) {
    print('  <Empty Response Body>');
  } else {
    try {
      // Attempt to pretty-print JSON response
      final decodedJson = jsonDecode(bodyStr);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(decodedJson);
      print(prettyJson);
    } catch (_) {
      // Print raw plain text
      print(bodyStr);
    }
  }
  print('===============================================\n');
}
