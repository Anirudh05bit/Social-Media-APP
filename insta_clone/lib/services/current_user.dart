import 'package:firebase_auth/firebase_auth.dart';

class CurrentUser {
  static String uid() => FirebaseAuth.instance.currentUser!.uid;

  static String usernameFallback() {
    final u = FirebaseAuth.instance.currentUser;
    return u?.displayName ?? u?.email?.split('@').first ?? "anonymous";
  }
}