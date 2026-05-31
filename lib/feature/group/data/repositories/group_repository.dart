
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
// your existing UserModel

class GroupRepository {
  // Get the Firestore instance — single source of truth
  final _firestore = FirebaseFirestore.instance;

  // Shorthand reference to the groups collection
  CollectionReference get _groups => _firestore.collection('groups');
  CollectionReference get _users  => _firestore.collection('users');

  // ── CREATE GROUP ────────────────────────────────────────────────────────
  // Returns the new group's document ID
  Future<String> createGroup(GroupModel group) async {
    // .add() auto-generates a document ID
    final doc = await _groups.add(group.toMap());

    // Also update the creator's user document with this new groupId
    // This lets you quickly fetch "all groups I belong to"
    await _users.doc(group.createdBy).update({
      'groupIds': FieldValue.arrayUnion([doc.id]),
    });

    return doc.id;
  }

  // ── GET USER'S GROUPS (REAL-TIME STREAM) ───────────────────────────────
  // Returns a Stream — Riverpod will listen to this
  // Every time Firestore data changes, the stream emits a new list
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _groups
        .where('members', arrayContains: userId)   // only groups user is in
        .orderBy('createdAt', descending: true)    // newest first
        .snapshots()                               // real-time stream
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromDocument(doc))
            .toList());
  }

  // ── GET SINGLE GROUP (REAL-TIME STREAM) ────────────────────────────────
  Stream<GroupModel> getGroupById(String groupId) {
    return _groups
        .doc(groupId)
        .snapshots()
        .map((doc) => GroupModel.fromDocument(doc));
  }

  // ── ADD MEMBER BY EMAIL ─────────────────────────────────────────────────
  // 1. Look up the user by email in the users collection
  // 2. If found, add them to the group
  Future<void> addMemberByEmail(String groupId, String email) async {
    // Query users collection for this email
    final query = await _users
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      // Throw a typed error — the UI will catch and display this
      throw Exception('No user found with email: $email');
    }

    final userDoc = query.docs.first;
    final userId = userDoc.id;
    final userData = userDoc.data() as Map<String, dynamic>;

    // Use a Firestore transaction — both writes succeed or both fail
    // This prevents a member being added to the group but not their user doc
    await _firestore.runTransaction((transaction) async {
      final groupRef = _groups.doc(groupId);

      transaction.update(groupRef, {
        // arrayUnion safely adds without duplicates
        'members': FieldValue.arrayUnion([userId]),
        // Add their info to memberDetails nested map
        'memberDetails.$userId': {
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          
        },
      });

      // Update the added user's groupIds list too
      transaction.update(_users.doc(userId), {
        'groupIds': FieldValue.arrayUnion([groupId]),
      });
    });
  }

  // ── LEAVE GROUP ─────────────────────────────────────────────────────────
  Future<void> leaveGroup(String groupId, String userId) async {
    await _firestore.runTransaction((transaction) async {
      transaction.update(_groups.doc(groupId), {
        'members': FieldValue.arrayRemove([userId]),
        'memberDetails.$userId': FieldValue.delete(),
      });

      transaction.update(_users.doc(userId), {
        'groupIds': FieldValue.arrayRemove([groupId]),
      });
    });
  }
}