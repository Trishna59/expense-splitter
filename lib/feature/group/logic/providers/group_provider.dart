// lib/feature/group/logic/providers/group_provider.dart
import 'package:Expenses_splitter/feature/auth/logic/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── REPOSITORY PROVIDER ────────────────────────────────────────────────────
// A single shared instance of GroupRepository across the app
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

// ── USER'S GROUPS STREAM ───────────────────────────────────────────────────
// StreamProvider automatically handles loading/error/data states
// It re-fetches whenever the current userId changes (e.g. after login)
final userGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  final repo = ref.watch(groupRepositoryProvider);

  // Watch the current user from your existing auth provider
  // Replace 'authStateProvider' with whatever you named yours
  final user = ref.watch(authStateProvider).value;

  if (user == null) return const Stream.empty();

  return repo.getUserGroups(user.uid);
});

// ── SINGLE GROUP STREAM ─────────────────────────────────────────────────────
// A "family" provider takes a parameter — here the groupId
// Usage in widget: ref.watch(groupProvider('groupId123'))
final groupProvider = StreamProvider.family<GroupModel, String>((ref, groupId) {
  final repo = ref.watch(groupRepositoryProvider);
  return repo.getGroupById(groupId);
});

// ── GROUP ACTIONS NOTIFIER ──────────────────────────────────────────────────
// For write operations (create, addMember, leave) we use AsyncNotifier
// It manages loading state for you automatically
class GroupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {} // nothing to initialize

  Future<String> createGroup({
    required String name,
    required String description,
    required String currency,
  }) async {
    final repo = ref.read(groupRepositoryProvider);
    final user = ref.read(authStateProvider).value!;

// Fetch user's name from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';
    
    final group = GroupModel(
      id: '',                     // Firestore will assign this
      name: name,
      description: description,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      members: [user.uid],
      memberDetails: {
        user.uid: MemberInfo(
          name: userName,
          email: user.email ?? '',
        ),
      },
      currency: currency,
    );

    state = const AsyncLoading();
    try {
      final groupId = await repo.createGroup(group);
      state = const AsyncData(null);
      return groupId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> addMember(String groupId, String email) async {
    final repo = ref.read(groupRepositoryProvider);
    state = const AsyncLoading();
    try {
      await repo.addMemberByEmail(groupId, email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final groupNotifierProvider =
    AsyncNotifierProvider<GroupNotifier, void>(GroupNotifier.new);