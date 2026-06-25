class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int xp;
  final int streak;
  final int quizzesTaken;
  final double accuracy;
  final List<String> badges;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.xp = 0,
    this.streak = 1,
    this.quizzesTaken = 0,
    this.accuracy = 0.0,
    this.badges = const [],
  });

  int get level => (xp / 100).floor() + 1;
  int get xpToNextLevel => 100 - (xp % 100);
  double get levelProgress => (xp % 100) / 100.0;

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    int? xp,
    int? streak,
    int? quizzesTaken,
    double? accuracy,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      accuracy: accuracy ?? this.accuracy,
      badges: badges ?? this.badges,
    );
  }
}
