import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePlan(Map<String, dynamic> planData) async {
    try {
      await _db.collection('travel_plans').add(planData);
    } catch (e) {
      print("Error saving plan: \$e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchSavedPlans(String userId) async {
    QuerySnapshot querySnapshot = await _db
        .collection("travel_plans")
        .where("userId", isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> plans = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["selectedTickets"] = data["selectedTickets"] ?? {};
      return data;
    }).toList();
    return plans;
  }

  Future<Map<String, dynamic>?> getPlanById(String planId) async {
    DocumentSnapshot doc =
        await _db.collection('travel_plans').doc(planId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updatePlanOrder(String userId, List<Map<String, dynamic>> plans) async {
    WriteBatch batch = _db.batch();
    CollectionReference plansRef = _db.collection("travel_plans");

    for (int i = 0; i < plans.length; i++) {
      String? docId = plans[i]["id"];
      if (docId != null) {
        batch.update(plansRef.doc(docId), {"order": i});
      }
    }
    await batch.commit();
  }
}
