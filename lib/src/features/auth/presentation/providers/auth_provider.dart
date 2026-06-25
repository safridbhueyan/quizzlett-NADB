import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthController extends StateNotifier<AuthState> {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  StreamSubscription<fb.User?>? _authStateSubscription;

  AuthController() : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    _authStateSubscription = _auth.authStateChanges().listen((fb.User? firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthInitial();
      } else {
        try {
          final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            state = Authenticated(UserModel(
              uid: firebaseUser.uid,
              displayName: data['displayName'] ?? firebaseUser.displayName ?? 'User',
              email: data['email'] ?? firebaseUser.email ?? '',
              photoUrl: data['photoUrl'] ?? firebaseUser.photoURL,
              xp: data['xp'] ?? 0,
              streak: data['streak'] ?? 1,
              quizzesTaken: data['quizzesTaken'] ?? 0,
              accuracy: (data['accuracy'] ?? 0.0).toDouble(),
              badges: List<String>.from(data['badges'] ?? []),
            ));
          } else {
            // Create user document if it doesn't exist
            final newUser = UserModel(
              uid: firebaseUser.uid,
              displayName: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
              photoUrl: firebaseUser.photoURL,
            );
            await _firestore.collection('users').doc(firebaseUser.uid).set({
              'displayName': newUser.displayName,
              'email': newUser.email,
              'photoUrl': newUser.photoUrl,
              'xp': newUser.xp,
              'streak': newUser.streak,
              'quizzesTaken': newUser.quizzesTaken,
              'accuracy': newUser.accuracy,
              'badges': newUser.badges,
            });
            state = Authenticated(newUser);
          }
        } catch (e) {
          state = AuthError('Error loading profile: ${e.toString()}');
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      state = AuthError(e.message ?? 'An error occurred during sign in.');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp(String displayName, String email, String password) async {
    state = const AuthLoading();
    
    if (displayName.trim().isEmpty) {
      state = const AuthError('Name cannot be empty.');
      return;
    }
    if (!email.contains('@')) {
      state = const AuthError('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      state = const AuthError('Password must be at least 6 characters.');
      return;
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final fbUser = credential.user;
      if (fbUser != null) {
        await fbUser.updateDisplayName(displayName.trim());
        
        final newUser = UserModel(
          uid: fbUser.uid,
          displayName: displayName.trim(),
          email: email,
        );
        await _firestore.collection('users').doc(fbUser.uid).set({
          'displayName': newUser.displayName,
          'email': newUser.email,
          'photoUrl': newUser.photoUrl,
          'xp': newUser.xp,
          'streak': newUser.streak,
          'quizzesTaken': newUser.quizzesTaken,
          'accuracy': newUser.accuracy,
          'badges': newUser.badges,
        });
        
        state = Authenticated(newUser);
      }
    } on fb.FirebaseAuthException catch (e) {
      state = AuthError(e.message ?? 'An error occurred during registration.');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          state = const AuthInitial();
        } else {
          _init(); 
        }
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      state = AuthError(e.message ?? 'An error occurred during Google sign in.');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      state = const AuthInitial();
    } catch (e) {
      state = AuthError('Error signing out: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    state = Authenticated(updatedUser);
    
    try {
      await _firestore.collection('users').doc(updatedUser.uid).set({
        'displayName': updatedUser.displayName,
        'email': updatedUser.email,
        'photoUrl': updatedUser.photoUrl,
        'xp': updatedUser.xp,
        'streak': updatedUser.streak,
        'quizzesTaken': updatedUser.quizzesTaken,
        'accuracy': updatedUser.accuracy,
        'badges': updatedUser.badges,
      });
    } catch (e) {
      // Local state remains updated even if Firestore fails
    }
  }

  Future<void> updateProfilePicture(String filePath) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child(currentUser.uid);
          
      final uploadTask = storageRef.putFile(File(filePath));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await currentUser.updatePhotoURL(downloadUrl);

      final currentState = state;
      if (currentState is Authenticated) {
        final updatedUser = currentState.user.copyWith(photoUrl: downloadUrl);
        await updateUser(updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
