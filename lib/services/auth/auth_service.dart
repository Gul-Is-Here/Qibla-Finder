import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GetStorage _storage = GetStorage();

  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isGuest = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
    isGuest.value = _storage.read('isGuest') ?? false;
  }

  // Sign Up with Email & Password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      print('🔥 Creating Firebase Auth user...');

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      currentUser.value = _auth.currentUser;

      // Create user document in Firestore
      if (userCredential.user != null) {
        print('📝 Creating user document in Firestore...');
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email.trim(),
          name: name,
          authProvider: 'email',
        );
        print('✅ User document created successfully!');
      }

      _storage.write('isGuest', false);
      _storage.write('hasCompletedOnboarding', true);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } catch (e) {
      print('❌ Unexpected error during sign up: $e');
      return 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In with Email & Password
  Future<String?> signInWithEmail({required String email, required String password}) async {
    try {
      isLoading.value = true;
      print('🔥 Signing in with email...');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last login time in Firestore
      if (userCredential.user != null) {
        print('📝 Updating last login time...');
        await _updateLastLogin(userCredential.user!.uid);
        print('✅ Last login updated!');
      }

      _storage.write('isGuest', false);
      _storage.write('hasCompletedOnboarding', true);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } catch (e) {
      print('❌ Unexpected error during sign in: $e');
      return 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In with Google
  Future<String?> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // iOS Check: Verify configuration
      if (Platform.isIOS) {
        // Check if GoogleService-Info.plist is configured
        // This will throw an error if not configured, which we catch below
        print('🍎 iOS: Attempting Google Sign-In...');
      }

      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Sign in cancelled';
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        print('📝 Creating/updating user document in Firestore...');
        await _createOrUpdateGoogleUser(userCredential.user!);
        print('✅ User document saved!');
      }

      _storage.write('isGuest', false);
      _storage.write('hasCompletedOnboarding', true);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      // Specific handling for iOS configuration error
      if (Platform.isIOS && e.toString().contains('presentingViewController')) {
        return 'Google Sign-In not configured for iOS.\n\nPlease follow setup instructions in URGENT_IOS_SETUP.md';
      }
      return 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Continue as Guest
  Future<void> continueAsGuest() async {
    _storage.write('isGuest', true);
    _storage.write('hasCompletedOnboarding', true);
    isGuest.value = true;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _storage.write('isGuest', false);
      isGuest.value = false;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Check if user is authenticated (not guest)
  bool get isAuthenticated => currentUser.value != null;

  // Check if onboarding is completed
  bool get hasCompletedOnboarding => _storage.read('hasCompletedOnboarding') ?? false;

  // Get user display name
  String get userDisplayName {
    if (isGuest.value) return 'Guest User';
    return currentUser.value?.displayName ?? currentUser.value?.email ?? 'User';
  }

  // Get user email
  String get userEmail {
    if (isGuest.value) return '';
    return currentUser.value?.email ?? '';
  }

  // Error message helper
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // ==================== FIRESTORE DATABASE METHODS ====================

  /// Create a new user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    required String authProvider,
  }) async {
    try {
      final userModel = UserModel.fromFirebaseUser(
        uid: uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
        authProvider: authProvider,
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      print('✅ User document created: $uid');
    } catch (e) {
      print('❌ Error creating user document: $e');
      // Don't throw error - auth is still successful even if Firestore fails
    }
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'lastLoginAt': Timestamp.now()});
      print('✅ Last login updated for: $uid');
    } catch (e) {
      print('⚠️ Error updating last login: $e');
      // If document doesn't exist, try to get user info and create it
      final user = _auth.currentUser;
      if (user != null) {
        await _createUserDocument(
          uid: uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          authProvider: 'email',
        );
      }
    }
  }

  /// Create or update Google user document
  Future<void> _createOrUpdateGoogleUser(User user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // User exists, just update last login
        await docRef.update({
          'lastLoginAt': Timestamp.now(),
          'photoUrl': user.photoURL, // Update photo in case it changed
        });
        print('✅ Google user updated: ${user.uid}');
      } else {
        // New user, create document
        await _createUserDocument(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Google User',
          photoUrl: user.photoURL,
          authProvider: 'google',
        );
        print('✅ New Google user created: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error creating/updating Google user: $e');
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  /// Stream user data from Firestore
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Delete user document from Firestore (when account is deleted)
  Future<void> _deleteUserDocument(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print('✅ User document deleted: $uid');
    } catch (e) {
      print('❌ Error deleting user document: $e');
    }
  }
}
