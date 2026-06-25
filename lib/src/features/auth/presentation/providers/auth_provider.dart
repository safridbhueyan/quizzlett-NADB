import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  AuthController() : super(const AuthInitial());

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (email.contains('@') && password.length >= 6) {
      final displayName = email.split('@').first;
      final capitalizedName = displayName.isNotEmpty
          ? displayName[0].toUpperCase() + displayName.substring(1)
          : 'User';
      
      final mockUser = UserModel(
        uid: 'mock_uid_${email.hashCode}',
        displayName: capitalizedName,
        email: email,
        xp: 120, // Start with some initial points to look good
        streak: 3,
        quizzesTaken: 2,
        accuracy: 0.75,
        badges: const ['Novice', 'Fast Learner'],
      );
      state = Authenticated(mockUser);
    } else {
      state = const AuthError('Invalid email or password (min 6 characters).');
    }
  }

  Future<void> signUp(String displayName, String email, String password) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 1500));
    
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

    final mockUser = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      displayName: displayName.trim(),
      email: email,
      xp: 0,
      streak: 1,
      quizzesTaken: 0,
      accuracy: 0.0,
      badges: const [],
    );
    state = Authenticated(mockUser);
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 2000));
    
    final mockUser = UserModel(
      uid: 'google_uid_987654',
      displayName: 'Alex Mercer',
      email: 'alex.mercer@gmail.com',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      xp: 350,
      streak: 7,
      quizzesTaken: 12,
      accuracy: 0.88,
      badges: const ['Novice', 'Fast Learner', 'Streak Master', 'Quiz Whiz'],
    );
    state = Authenticated(mockUser);
  }

  void signOut() {
    state = const AuthInitial();
  }

  void updateUser(UserModel updatedUser) {
    if (state is Authenticated) {
      state = Authenticated(updatedUser);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
