import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../components/api_service.dart';
import '../components/ticket_card.dart';

class TrainBookingPage extends StatefulWidget {
  final List<Map<String, String>> trainRoutes;

  const TrainBookingPage({super.key, required this.trainRoutes});

  @override
  State<TrainBookingPage> createState() => _TrainBookingPageState();
}

class _TrainBookingPageState extends State<TrainBookingPage> {
  List<Map<String, dynamic>> trainTickets = [];
  bool isLoading = false;
  Map<String, String> selectedTickets = {}; 

  Map<String, String> selectedDates = {};
  Map<String, String?> selectedTimes = {};

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _fetchTrainTickets();
  }

  void _initializeDates() {
    String today = DateFormat('yyyyMMdd').format(DateTime.now()); 
    String currentTime = DateFormat('HH:mm').format(DateTime.now());

    for (var route in widget.trainRoutes) {
      final routeKey = "${route['departure']} → ${route['arrival']}";
      selectedDates.putIfAbsent(routeKey, () => today);
      selectedTimes.putIfAbsent(routeKey, () => currentTime);
    }
  }

  Future<void> _fetchTrainTickets() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> fetchedTickets = [];

    for (var route in widget.trainRoutes) {
      String departure = route['departure']!;
      String arrival = route['arrival']!;
      String routeKey = "$departure → $arrival";
      String departureDate = selectedDates[routeKey] ?? "20250201";
      String? departureTime = selectedTimes[routeKey];

      try {
         final List<Map<String, dynamic>> trains =
            await ApiService.getTrainRoutes(
          origin: departure,
          destination: arrival,
          departureDate: departureDate,
          departureTime: departureTime,
        );
        for (var train in trains) {
          fetchedTickets.add({
            ...train, 
            "routeKey": routeKey 
          });
        }
      } catch (e) {
      }
    }

    setState(() {
      isLoading = false;
      trainTickets = fetchedTickets;
    });
  }

  void _selectDate(BuildContext context, String routeKey) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        String newDate = DateFormat('yyyyMMdd').format(picked);
        int routeIndex = widget.trainRoutes.indexWhere((route) =>
            "${route['departure']} → ${route['arrival']}" == routeKey);

        if (routeIndex != -1) {
          selectedDates[routeKey] = newDate;
          for (int i = routeIndex + 1; i < widget.trainRoutes.length; i++) {
            final nextRouteKey =
                "${widget.trainRoutes[i]['departure']} → ${widget.trainRoutes[i]['arrival']}";
            selectedDates[nextRouteKey] = newDate;
          }
        }
      });
      _fetchTrainTickets();
    }
  }

  Future<void> _selectTime(BuildContext context, String routeKey) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        String newTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

        int routeIndex = widget.trainRoutes.indexWhere((route) =>
            "${route['departure']} → ${route['arrival']}" == routeKey);

        if (routeIndex != -1) {
          selectedTimes[routeKey] = newTime;

          for (int i = routeIndex + 1; i < widget.trainRoutes.length; i++) {
            final nextRouteKey =
                "${widget.trainRoutes[i]['departure']} → ${widget.trainRoutes[i]['arrival']}";
            selectedTimes[nextRouteKey] = newTime;
          }
        }
      });
      _fetchTrainTickets();
    }
  }

  void _toggleSelection(String routeKey, String ticketId) {
    setState(() {
      if (selectedTickets[routeKey] == ticketId) {
        selectedTickets.remove(routeKey); 
      } else {
        selectedTickets[routeKey] = ticketId as String; 
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Train Booking")),
      body: LayoutBuilder(
  builder: (context, constraints) {
    bool isTablet = constraints.maxWidth > 800; 
    double itemWidth = isTablet ? constraints.maxWidth / 2 - 24 : constraints.maxWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 10, 
                children: List.generate(widget.trainRoutes.length, (routeIndex) {
                  final route = widget.trainRoutes[routeIndex];
                  final routeKey = "${route['departure']} → ${route['arrival']}";

                  List<Map<String, dynamic>> filteredTickets =
                      trainTickets.where((ticket) => ticket["routeKey"] == routeKey).toList();

                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.train, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(routeKey,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _selectDate(context, routeKey),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                        "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(selectedDates[routeKey]!))}"),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _selectTime(context, routeKey),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                        "Time: ${selectedTimes[routeKey] ?? DateFormat('HH:mm').format(DateTime.now())}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...filteredTickets.map((ticket) {
                          final ticketId =
                              "${ticket["departureTime"]}_${ticket["arrivalTime"]}";
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TicketCard(
                              departureTime: ticket["departureTime"] ?? "Unknown",
                              arrivalTime: ticket["arrivalTime"] ?? "Unknown",
                              duration: ticket["duration"] ?? "Unknown",
                              departureStation:
                                  ticket["departureStation"] ?? "Unknown",
                              arrivalStation:
                                  ticket["arrivalStation"] ?? "Unknown",
                              operatorName: ticket["trainOperator"] ?? "Unknown",
                              price: "5.20 €",
                              changes: ticket["changes"] ?? 0,
                              isSelected: selectedTickets[routeKey] == ticketId, 
                              onTap: () => _toggleSelection(routeKey, ticketId),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Map<String, Map<String, dynamic>> result = {};
          selectedTickets.forEach((routeKey, ticketId) {
            var ticket = trainTickets.firstWhere(
              (t) =>
                  t["routeKey"] == routeKey &&
                  "${t['departureTime']}_${t['arrivalTime']}" == ticketId,
            );
            result[routeKey] = ticket;
          });
          Get.back(result: result);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
