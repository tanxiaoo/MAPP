import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../components/firestore_service.dart';
import '../const.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Map<String, dynamic> _convertToRouteDetails(List<dynamic> routes) {
    Map<String, dynamic> routeDetails = {};

    for (int i = 0; i < routes.length; i++) {
      String key = "${i}_${i + 1}";
      if (routes[i] is Map<String, dynamic> && routes[i]["transports"] is List) {
        routeDetails[key] = List<Map<String, dynamic>>.from(routes[i]["transports"]);
      }
    }
    return routeDetails;
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final waypointsTitles = (plan["routes"] as List<dynamic>)
    .map((r) => r["waypoint"].toString()) 
    .toList();

    final routeDetails = _convertToRouteDetails(plan["routes"]);

    Map<String, dynamic> selectedTickets = {};
  if (plan.containsKey("selectedTickets") && plan["selectedTickets"] is Map) {
    selectedTickets = Map<String, dynamic>.from(plan["selectedTickets"]);
  }

  String formattedDateRange = "No Dates"; 
  DateTime? startDate;
  DateTime? endDate;
  if (plan["date"] != null && plan["date"] != "Not selected") {
    try {
      List<String> dates = plan["date"].split(" - "); 
      if (dates.length == 2) {
        startDate = DateTime.parse(dates[0]);
        endDate = DateTime.parse(dates[1]);
        formattedDateRange =
            "${DateFormat("ddMMyyyy").format(startDate)} - ${DateFormat("ddMMyyyy").format(endDate)}"; // ✅ 转换格式
      }
    } catch (e) {
    }
  }

  DateTime today = DateTime.now();
  Widget statusIcon;
  if (endDate != null && today.isAfter(endDate)) {
    statusIcon = _buildStatusIcon(Colors.purple, Colors.purple[100]!, "Done");
  } else if (startDate != null && endDate != null && today.isAfter(startDate) && today.isBefore(endDate)) {
    statusIcon = _buildStatusIcon(Colors.brown, Colors.amber[200]!, "In Progress");
  } else {
    statusIcon = _buildStatusIcon(Colors.green, Colors.green[100]!, "To Do");
  }

    return Card(
    margin: const EdgeInsets.all(8),
    child: ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Text(plan["planName"] ?? "No planName"),
          ),
          statusIcon, 
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            "${waypointsTitles.length} waypoints",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Spacer(), 
          Text(
            formattedDateRange,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      children: [
       _buildPlanContent(plan, waypointsTitles, routeDetails, selectedTickets), 

      ],
    ),
  );
}

  Widget _buildStatusIcon(Color borderColor, Color fillColor, String statusText) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          color: fillColor,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        statusText,
        style: TextStyle(color: borderColor, fontSize: 12,),
      ),
    ],
  );
}

  Widget _buildPlanContent(
    Map<String, dynamic> plan,
    List<String> waypointsTitles,
    Map<String, dynamic> routeDetails,
    Map<String, dynamic> selectedTickets, 
  ) {
  return Column(
    children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: waypointsTitles.length * 2 - 1,
        itemBuilder: (context, index) {
          if (index.isEven) {
            int actualIndex = index ~/ 2;
            return _buildWaypointTile(actualIndex, waypointsTitles);
          } else {
            int routeIndex = (index - 1) ~/ 2;
            return _buildTransportDetails(routeIndex, routeDetails, selectedTickets); 
          }
        },
      ),
    ],
  );
}


  Widget _buildWaypointTile(int index, List<String> waypointsTitles) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.blue,
        child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
      ),
      title: Text(waypointsTitles[index]),
    );
  }

Widget _buildTransportDetails(int index, Map<String, dynamic> routeDetails, Map<String, dynamic> selectedTickets) { // ✅ 添加 selectedTickets
  String routeKey = "${index}_${index + 1}";
  List transports = routeDetails[routeKey] ?? [];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: transports.map<Widget>((transport) {
        bool isWalking = transport["mode"].toLowerCase() == "walking";

        return ListTile(
          dense: true,
          leading: _getTransportIcon(
            transport["mode"],
            departure: transport["departure"],
            arrival: transport["arrival"],
            selectedTickets: selectedTickets, 
          ),
          title: Text(
            isWalking ? "Walking" : "${transport["mode"]} ${transport["line"]}",
          ),
          subtitle: isWalking ? null : Text("${transport["departure"]} → ${transport["arrival"]}"),
          trailing: Text("${transport["duration"]}"),
        );
      }).toList(),
    ),
  );
}

  Widget _getTransportIcon(String mode, {String? departure, String? arrival, Map<String, dynamic>? selectedTickets}) {
  if (mode.toLowerCase() == "train" && departure != null && arrival != null) {
    final routeKey = "$departure → $arrival";
    bool isSelected = selectedTickets?.containsKey(routeKey) ?? false; 

    return GestureDetector(
      onTap: isSelected ? () => _showTicketDetails(routeKey, selectedTickets!) : null, 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.train, color: isSelected ? Colors.green : Colors.red), 
          if (isSelected)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.info_outline, size: 16, color: Colors.grey), 
            ),
        ],
      ),
    );
  }

  switch (mode.toLowerCase()) {
    case "walking":
      return const Icon(Icons.directions_walk, color: Colors.grey);
    case "bus":
      return const Icon(Icons.directions_bus, color: Colors.grey);
    default:
      return const Icon(Icons.directions, color: Colors.grey);
  }
}


void _showTicketDetails(String routeKey, Map<String, dynamic> selectedTickets) {
  final ticketData = selectedTickets[routeKey];
  if (ticketData == null) return;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Ticket Details - $routeKey",
        style: const TextStyle(fontSize: 16, color: Colors.green),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Departure Time", ticketData["departureTime"]),
          _buildDetailRow("Arrival Time", ticketData["arrivalTime"]),
          _buildDetailRow("Duration", ticketData["duration"]),
          _buildDetailRow("Operator", ticketData["trainOperator"]),
          _buildDetailRow("Price", ticketData["price"] ?? "N/A"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text("$label：", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(value ?? "N/A"),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    String? userId = getCurrentUserId();
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view saved plans.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("list"),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.green,
      ),
      body: LayoutBuilder(
  builder: (context, constraints) {
    bool isTablet = constraints.maxWidth > 800; 
    double itemWidth = isTablet ? constraints.maxWidth / 2 - 24 : constraints.maxWidth;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestoreService.fetchSavedPlans(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No saved plans."));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: isTablet
                ? Wrap(
                    spacing: 16, 
                    runSpacing: 10, 
                    children: List.generate(snapshot.data!.length, (index) {
                      final plan = snapshot.data![index];

                      return SizedBox(
                        width: itemWidth,
                        child: _buildPlanCard(plan),
                      );
                    }),
                  )
                : Column( 
                    children: snapshot.data!.map((plan) => _buildPlanCard(plan)).toList(),
                  ),
          ),
        );
      },
    );
  },
),

    );
  }
}
