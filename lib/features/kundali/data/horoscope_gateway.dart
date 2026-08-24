import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/sync/account_service.dart';
import '../domain/birth_profile.dart';
import '../domain/horoscope_reading.dart';

class HoroscopeException implements Exception {
  const HoroscopeException(this.message);
  final String message;
}

/// Calls the trusted Prokerala proxy. The Flutter app never sees client secrets.
class HoroscopeGateway {
  HoroscopeGateway({AccountService? accountService})
    : _accountService = accountService ?? AccountService();

  static const String _region = 'asia-south1';

  final AccountService _accountService;

  Future<HoroscopeReading> draw(
    BirthProfile profile, {
    required bool hindi,
  }) async {
    final data = await _call('drawHoroscope', profile.toGatewayMap(hindi: hindi));
    final reading = HoroscopeReading.fromMap(data['reading']) ??
        HoroscopeReading.fromVendor(
          data: _asMap(data['reading']),
          placeLabel: profile.placeLabel,
          datetime: profile.toIso8601(),
        );
    if (!reading.hasLimbs) {
      throw const HoroscopeException(
        'The chart came back empty. Try again in a moment.',
      );
    }
    return reading;
  }

  Future<HoroscopeChatTurn> ask(
    BirthProfile profile,
    String message, {
    required bool hindi,
  }) async {
    final data = await _call('askHoroscope', {
      ...profile.toGatewayMap(hindi: hindi),
      'message': message.trim(),
    });
    final turn = HoroscopeChatTurn.fromMap(data['turn']);
    if (turn == null || turn.answer.isEmpty) {
      throw const HoroscopeException('No answer came back.');
    }
    return turn;
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> payload,
  ) async {
    if (!FirebaseBootstrap.isAvailable) {
      throw const HoroscopeException(
        'Cloud features are not available in this build.',
      );
    }
    final uid = await _accountService.ensureSignedIn();
    if (uid == null) {
      throw const HoroscopeException(
        'Could not create an anonymous session for kundali.',
      );
    }

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: _region,
      ).httpsCallable(name);
      final result = await callable.call(payload);
      return _asMap(result.data);
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Horoscope callable $name failed: ${error.code} ${error.message}');
      throw HoroscopeException(_messageFor(error));
    } on HoroscopeException {
      rethrow;
    } on Object catch (error) {
      debugPrint('Horoscope callable $name failed: $error');
      throw const HoroscopeException(
        'The kundali service could not be reached.',
      );
    }
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  static String _messageFor(FirebaseFunctionsException error) {
    return switch (error.code) {
      'unauthenticated' =>
        'Sign-in is required for kundali. It is anonymous and stays on this device.',
      'failed-precondition' =>
        'Horoscope is not configured on the server yet.',
      'resource-exhausted' =>
        'Daily limit reached. Try again tomorrow.',
      'invalid-argument' =>
        error.message ?? 'That birth detail was not accepted.',
      _ => error.message ?? 'The kundali service could not be reached.',
    };
  }
}
