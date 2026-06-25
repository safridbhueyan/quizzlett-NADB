import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizlett/core/constant/app_colors.dart';
import 'package:quizlett/src/features/auth/presentation/providers/auth_provider.dart';

class LeaderboardUser {
  final String name;
  final int xp;
  final int level;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.name,
    required this.xp,
    required this.level,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

final leaderboardProvider = StreamProvider<List<LeaderboardUser>>((ref) {
  final authState = ref.watch(authControllerProvider);
  final currentUserId = authState is Authenticated ? authState.user.uid : null;

  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('xp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs.map<LeaderboardUser>((doc) {
          final data = doc.data();
          final uid = doc.id;
          final name = data['displayName'] ?? 'User';
          final xp = data['xp'] ?? 0;
          final level = (xp / 100).floor() + 1;
          final avatarUrl = data['photoUrl'];
          
          return LeaderboardUser(
            name: name,
            xp: xp,
            level: level,
            avatarUrl: avatarUrl,
            isCurrentUser: uid == currentUserId,
          );
        }).toList();

        // Ensure current user is in the list
        final hasCurrentUser = list.any((u) => u.isCurrentUser);
        if (!hasCurrentUser && authState is Authenticated) {
          list.add(LeaderboardUser(
            name: authState.user.displayName,
            xp: authState.user.xp,
            level: authState.user.level,
            avatarUrl: authState.user.photoUrl,
            isCurrentUser: true,
          ));
        }

        // Sort first
        list.sort((a, b) => b.xp.compareTo(a.xp));

        // We want at least 10 users on the leaderboard to make it look full.
        const targetLeaderboardCount = 10;
        final realUserCount = list.length;
        if (realUserCount < targetLeaderboardCount) {
          final dummyCountNeeded = targetLeaderboardCount - realUserCount;
          final dummyPool = [
            const LeaderboardUser(
              name: 'Sarah Connor',
              xp: 480,
              level: 5,
              avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
            ),
            const LeaderboardUser(
              name: 'Bruce Wayne',
              xp: 380,
              level: 4,
              avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
            ),
            const LeaderboardUser(
              name: 'Tony Stark',
              xp: 320,
              level: 4,
              avatarUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
            ),
            const LeaderboardUser(
              name: 'Clark Kent',
              xp: 260,
              level: 3,
              avatarUrl: 'https://randomuser.me/api/portraits/men/85.jpg',
            ),
            const LeaderboardUser(
              name: 'Peter Parker',
              xp: 190,
              level: 2,
              avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
            ),
            const LeaderboardUser(
              name: 'Selina Kyle',
              xp: 150,
              level: 2,
              avatarUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
            ),
            const LeaderboardUser(
              name: 'Barry Allen',
              xp: 110,
              level: 2,
              avatarUrl: 'https://randomuser.me/api/portraits/men/18.jpg',
            ),
            const LeaderboardUser(
              name: 'Diana Prince',
              xp: 80,
              level: 1,
              avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
            ),
            const LeaderboardUser(
              name: 'Arthur Curry',
              xp: 40,
              level: 1,
              avatarUrl: 'https://randomuser.me/api/portraits/men/62.jpg',
            ),
            const LeaderboardUser(
              name: 'Hal Jordan',
              xp: 20,
              level: 1,
              avatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
            ),
          ];
          
          // Take the required amount of dummy users
          final dummiesToAdd = dummyPool.take(dummyCountNeeded);
          list.addAll(dummiesToAdd);
          
          // Re-sort the list with the added dummy users
          list.sort((a, b) => b.xp.compareTo(a.xp));
        }

        return list;
      });
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'All-Time'),
          ],
        ),
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load leaderboard',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(leaderboardProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (allUsers) {
          // Split into Top 3 and Rest
          final top3 = allUsers.take(3).toList();
          final restUsers = allUsers.skip(3).toList();

          // Reorder top 3 for podium visualization: [Rank 2, Rank 1, Rank 3]
          List<LeaderboardUser?> podiumUsers = [null, null, null];
          if (top3.isNotEmpty) {
            if (top3.length > 1) podiumUsers[0] = top3[1]; // Rank 2
            podiumUsers[1] = top3[0];                      // Rank 1
            if (top3.length > 2) podiumUsers[2] = top3[2]; // Rank 3
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(3, (tabIdx) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  // 1. Podium Section
                  Container(
                    height: 290,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Rank 2 Podium
                        Expanded(
                          child: podiumUsers[0] != null
                              ? _buildPodiumColumn(context, podiumUsers[0]!, 2, 110.0, const Color(0xFF94A3B8))
                              : const SizedBox(),
                        ),
                        // Rank 1 Podium
                        Expanded(
                          child: podiumUsers[1] != null
                              ? _buildPodiumColumn(context, podiumUsers[1]!, 1, 140.0, const Color(0xFFF59E0B))
                              : const SizedBox(),
                        ),
                        // Rank 3 Podium
                        Expanded(
                          child: podiumUsers[2] != null
                              ? _buildPodiumColumn(context, podiumUsers[2]!, 3, 90.0, const Color(0xFFD97706))
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Rankings List Section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: restUsers.isEmpty
                          ? const Center(
                              child: Text('No additional rankings yet.'),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                              itemCount: restUsers.length,
                              separatorBuilder: (context, index) => Divider(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final user = restUsers[index];
                                final rank = index + 4;
                                return _buildLeaderboardTile(context, user, rank);
                              },
                            ),
                    ),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildPodiumColumn(
    BuildContext context,
    LeaderboardUser user,
    int rank,
    double height,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar stack
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Avatar glowing ring
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 32 : 26,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: rank == 1 ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      )
                    : null,
              ),
            ),
            // Crown / Badge overlay
            if (rank == 1)
              const Positioned(
                top: -24,
                child: Text(
                  '👑',
                  style: TextStyle(fontSize: 24),
                ),
              )
            else
              Positioned(
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Name
        Text(
          user.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: user.isCurrentUser ? theme.colorScheme.primary : null,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Score
        Text(
          '${user.xp} XP',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        // 3D Block
        Container(
          height: height,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [accentColor.withValues(alpha: 0.15), accentColor.withValues(alpha: 0.05)]
                  : [accentColor.withValues(alpha: 0.12), accentColor.withValues(alpha: 0.03)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            rank == 1 
                ? '1st' 
                : rank == 2 
                    ? '2nd' 
                    : '3rd',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, LeaderboardUser user, int rank) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: user.isCurrentUser
            ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Rank index
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: user.isCurrentUser 
                    ? theme.colorScheme.primary 
                    : isDark 
                        ? AppColors.textMutedDark 
                        : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // User Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // User Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: user.isCurrentUser ? theme.colorScheme.primary : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Level ${user.level}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          // User XP score
          Text(
            '${user.xp} XP',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: user.isCurrentUser ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
