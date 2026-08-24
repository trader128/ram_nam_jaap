import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_bootstrap.dart';

/// Gives the device a stable identity for cloud backup without a login wall.
///
/// Sign-in is anonymous and happens silently in the background. The user is
/// never asked to create an account to chant; an email/phone upgrade can be
/// linked onto the same anonymous uid later without losing history.
class AccountService {
  Future<String?> ensureSignedIn() async {
    if (!FirebaseBootstrap.isAvailable) {
      return null;
    }

    try {
      final auth = FirebaseAuth.instance;
      final existing = auth.currentUser;
      if (existing != null) {
        return existing.uid;
      }

      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } on Object catch (error) {
      debugPrint('Anonymous sign-in failed, staying local-only: $error');
      return null;
    }
  }

  String? get currentUid {
    if (!FirebaseBootstrap.isAvailable) {
      return null;
    }
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } on Object {
      return null;
    }
  }

  Future<void> signOut() async {
    if (!FirebaseBootstrap.isAvailable) {
      return;
    }
    try {
      await FirebaseAuth.instance.signOut();
    } on Object catch (error) {
      debugPrint('Sign-out failed: $error');
    }
  }
}
