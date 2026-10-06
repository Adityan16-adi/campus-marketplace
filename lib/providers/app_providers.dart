import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final listingsProvider =
    StreamProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) {
    return FirebaseFirestore.instance
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  },
);

final searchProvider = StateProvider<String>((ref) => '');

final categoryProvider = StateProvider<String>((ref) => 'All');

final wishlistProvider = StateProvider<Set<String>>((ref) => {});

final themeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);