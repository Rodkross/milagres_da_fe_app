import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> fixPhotos() async {
  final current = await FirebaseFirestore.instance.collection('escala').doc('current').get();
  if (!current.exists) return;
  final data = current.data()!;
  final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
  
  for (var i = 0; i < assignments.length; i++) {
    final a = assignments[i];
    final nameStr = a['name'] as String; // e.g. "Pastor Rodrigo"
    final rawName = nameStr.split(' ').skip(1).join(' '); // "Rodrigo"
    
    // search user
    final qs = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: rawName).get();
    if (qs.docs.isNotEmpty) {
      final u = qs.docs.first.data();
      assignments[i]['photoUrl'] = u['photoUrl'] ?? '';
      print('Found photo for $rawName: ${u['photoUrl']}');
    }
  }
  await FirebaseFirestore.instance.collection('escala').doc('current').set({'assignments': assignments}, SetOptions(merge: true));
}
