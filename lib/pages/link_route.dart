import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/yellow_button.dart';
import '../const.dart';
import 'package:intl/intl.dart';
import '../components/api_service.dart';
import '../components/ticket_card.dart';
import '../components/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinkRoutePage extends StatefulWidget {
  final List<String> waypointsTitles;
  final Map<String, dynamic> routeDetails;

  const LinkRoutePage(
      {super.key, required this.waypointsTitles, required this.routeDetails});

  @override
  State<LinkRoutePage> createState() => _LinkRoutePageState();
}

class _LinkRoutePageState extends State<LinkRoutePage> {
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedDateRange;
  Map<int, bool> expandedState = {};
  Set<String> selectedTrainRoutes = {};
  Map<String, Map<String, dynamic>> selectedTickets = {};
  final FirestoreService firestoreService = FirestoreService();

  void _onTrainSelected(Map<String, Map<String, dynamic>>? ticketsData) {
    if (ticketsData != null) {
      setState(() {
        selectedTickets.addAll(ticketsData);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.waypointsTitles.length; i++) {
      expandedState[i] = true;
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
    });
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectedDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  List<Map<String, String>> getTrainRoutes() {
    List<Map<String, String>> trainRoutes = [];

    widget.routeDetails.forEach((key, transportDetails) {
      for (var detail in transportDetails) {
        if (detail['mode'].toLowerCase() == "train") {
          trainRoutes.add({
            "departure": detail['departure'],
            "arrival": detail['arrival'],
          });
        }
      }
    });

    return trainRoutes;
  }

  void _showTicketDetails(String routeKey) {
    final ticketData = selectedTickets[routeKey];
    if (ticketData == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Ticket Details - $routeKey",
          style: TextStyle(fontSize: 16, color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Departure Time", ticketData["departureTime"]),
            _buildDetailRow("Arrival Time", ticketData["arrivalTime"]),
            _buildDetailRow("Duration", ticketData["duration"]),
            _buildDetailRow("Operator", ticketData["trainOperator"]),
            _buildDetailRow("Price", ticketData["price"] ?? "5.20 €"),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label：", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildPlanData(String planName) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return {};
    }

    return {
      "userId": userId,
      "planName": planName,
      "date": selectedDateRange != null
          ? "${selectedDateRange!.start.toIso8601String()} - ${selectedDateRange!.end.toIso8601String()}"
          : "Not selected",
      "routes": widget.waypointsTitles.asMap().entries.map((entry) {
        int index = entry.key;
        String waypoint = entry.value;
        String routeKey = "${index}_${index + 1}";
        List transportDetails = widget.routeDetails[routeKey] ?? [];

        return {
          "waypoint": waypoint,
          "expanded": expandedState[index] ?? true,
          "transports": transportDetails.map((detail) {
            return {
              "mode": detail["mode"],
              "line": detail["line"] ?? "",
              "departure": detail["departure"] ?? "",
              "arrival": detail["arrival"] ?? "",
              "distance": detail["distance"] ?? "",
              "duration": detail["duration"] ?? "",
            };
          }).toList()
        };
      }).toList(),
    };
  }

  Future<void> _showPlanNameDialog() async {
    TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Give your route a name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter plan name"),
          ),
          actions: [
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("SAVE"),
              onPressed: () async {
                String planName = nameController.text.trim();
                if (planName.isNotEmpty) {
                  Navigator.of(context).pop();
                  _savePlan(planName);
                } else {
                  Get.snackbar("Error", "Plan name cannot be empty!");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePlan(String planName) async {
    final planData = _buildPlanData(planName);

    if (planData.isNotEmpty) {
      await firestoreService.savePlan(planData);
      Get.snackbar("Success", "Your travel plan has been saved.");
    } else {
      Get.snackbar("Error", "Failed to save plan. Please log in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("link "),
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
            double itemWidth =
                isTablet ? constraints.maxWidth / 2 - 24 : constraints.maxWidth;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: isTablet
                    ? Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: List.generate(widget.waypointsTitles.length,
                            (index) {
                          String waypoint = widget.waypointsTitles[index];
                          String routeKey = "${index}_${index + 1}";
                          List transportDetails =
                              widget.routeDetails[routeKey] ?? [];

                          return SizedBox(
                            width: itemWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        waypoint,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _toggleExpand(index),
                                      icon: Icon(
                                        expandedState[index] ?? false
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((expandedState[index] ?? false) &&
                                    transportDetails.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(
                                          thickness: 0.5, color: Colors.grey),
                                      ...transportDetails.map<Widget>((detail) {
                                        bool isWalking =
                                            detail['mode'].toLowerCase() ==
                                                "walking";
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                _getTransportIcon(
                                                    detail['mode'],
                                                    departure:
                                                        detail['departure'],
                                                    arrival: detail['arrival']),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    "${detail['mode']}${detail['line'].isNotEmpty ? ' - ${detail['line']}' : ''}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${detail['distance']} | ${detail['duration']}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!isWalking)
                                              Text(
                                                "${detail['departure']} → ${detail['arrival']}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        );
                                      }),
                                      const Divider(
                                          thickness: 0.5, color: Colors.grey),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        }),
                      )
                    : Column(
                        children: List.generate(widget.waypointsTitles.length,
                            (index) {
                          String waypoint = widget.waypointsTitles[index];
                          String routeKey = "${index}_${index + 1}";
                          List transportDetails =
                              widget.routeDetails[routeKey] ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      "${index + 1}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      waypoint,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _toggleExpand(index),
                                    icon: Icon(
                                      expandedState[index] ?? false
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if ((expandedState[index] ?? false) &&
                                  transportDetails.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                        thickness: 0.5, color: Colors.grey),
                                    ...transportDetails.map<Widget>((detail) {
                                      bool isWalking =
                                          detail['mode'].toLowerCase() ==
                                              "walking";
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _getTransportIcon(detail['mode'],
                                                  departure:
                                                      detail['departure'],
                                                  arrival: detail['arrival']),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  "${detail['mode']}${detail['line'].isNotEmpty ? ' - ${detail['line']}' : ''}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${detail['distance']} | ${detail['duration']}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (!isWalking)
                                            Text(
                                              "${detail['departure']} → ${detail['arrival']}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                        ],
                                      );
                                    }),
                                    const Divider(
                                        thickness: 0.5, color: Colors.grey),
                                  ],
                                ),
                            ],
                          );
                        }),
                      ),
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            YellowButton(
              onPressed: _showPlanNameDialog,
              iconUrl: 'lib/images/plan_save.svg',
              label: "Save Plan",
            ),
            YellowButton(
              onPressed: () async {
                List<Map<String, String>> trainRoutes = getTrainRoutes();
                if (trainRoutes.isNotEmpty) {
                  final result = await Get.toNamed("/train_booking",
                      arguments: trainRoutes);
                  if (result != null) {
                    _onTrainSelected(result);
                  }
                } else {
                  Get.snackbar(
                      "No Train Routes", "No available train routes to book.");
                }
              },
              iconUrl: 'lib/images/Card.svg',
              label: "Buy Tickets",
            ),
          ]),
        ));
  }

  Widget _getTransportIcon(String mode, {String? departure, String? arrival}) {
    if (mode.toLowerCase() == "train" && departure != null && arrival != null) {
      final routeKey = "$departure → $arrival";
      bool isSelected = selectedTickets.containsKey(routeKey);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed("/train_booking", arguments: [
                {"departure": departure, "arrival": arrival}
              ]);
              _onTrainSelected(result);
            },
            child: Icon(Icons.train,
                color: isSelected ? Colors.green : Colors.red),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => _showTicketDetails(routeKey),
                child: const Icon(Icons.info_outline,
                    size: 16, color: Colors.grey),
              ),
            ),
        ],
      );
    }

    switch (mode.toLowerCase()) {
      case "walking":
        return const Icon(Icons.directions_walk, color: Colors.grey);
      case "bus":
        return const Icon(Icons.directions_bus, color: Colors.grey);
      case "train":
        return const Icon(Icons.train, color: Colors.red);
      case "subway":
        return const Icon(Icons.subway, color: Colors.grey);
      case "tram":
        return const Icon(Icons.tram, color: Colors.grey);
      case "ferry":
        return const Icon(Icons.directions_boat, color: Colors.grey);
      default:
        return const Icon(Icons.directions, color: Colors.grey);
    }
  }
}
