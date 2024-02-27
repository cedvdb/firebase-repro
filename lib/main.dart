import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  final house = House(windows: 1, bathrooms: 1, toilets: 1);

  final housesRef =
      FirebaseFirestore.instance.collection('houses').withConverter(
    fromFirestore: (snapshot, options) {
      final data = snapshot.data();
      if (data == null) return null;
      return House.fromMap(data);
    },
    toFirestore: (value, options) {
      return value?.toMap() ?? {};
    },
  );

  //  initial save
  await housesRef.doc('house-id').set(house);

  await Future.wait([
    // user 1 update
    housesRef.doc('house-id').set(house.copyWith(toilets: 2)),
    // user 2 update
    housesRef.doc('house-id').set(house.copyWith(windows: 2)),
  ]);

  print('done');

  // expected result: { bathrooms: 1, toilets: 2, windows: 2 }
  // actual result: variable
}

class House {
  final int windows;
  final int bathrooms;
  final int toilets;

  House({
    required this.windows,
    required this.bathrooms,
    required this.toilets,
  });

  House copyWith({
    int? windows,
    int? bathrooms,
    int? toilets,
  }) {
    return House(
      windows: windows ?? this.windows,
      bathrooms: bathrooms ?? this.bathrooms,
      toilets: toilets ?? this.toilets,
    );
  }

  Map<String, dynamic> toMap() => {
        'windows': windows,
        'toilets': toilets,
        'bathrooms': bathrooms,
      };

  factory House.fromMap(Map<String, dynamic> map) {
    return House(
      windows: map['windows'],
      bathrooms: map['bathrooms'],
      toilets: map['toilets'],
    );
  }
}
