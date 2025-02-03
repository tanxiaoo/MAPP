import 'package:flutter/material.dart';
import '../components/yellow_button.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../pages/link_route.dart';

class PlanSaveCard extends StatelessWidget {
  final List<LatLng> waypoints;
  final List<String> waypointsTitles;
  final Map<String, dynamic> routeDetails;
  final Function(List<LatLng>, List<String>) onReorderCompleted;
  const PlanSaveCard(
      {super.key,
      required this.waypoints,
      required this.onReorderCompleted,
      required this.waypointsTitles,
      required this.routeDetails});

  void _showRouteList(BuildContext context) {
    List<LatLng> mutableWaypoints = List.from(waypoints);
    List<String> mutableTitles = List.from(waypointsTitles);
    Get.defaultDialog(
      title: "Selected Route",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: StatefulBuilder(builder: (context, setState) {
        return SizedBox(
          width: Get.width * 0.8,
          height: 300,
          child: Column(
            children: [
              Expanded(
                  child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        setState(
                          () {
                            final LatLng item =
                                mutableWaypoints.removeAt(oldIndex);
                            final String title =
                                mutableTitles.removeAt(oldIndex);
                            mutableWaypoints.insert(newIndex, item);
                            mutableTitles.insert(newIndex, title);
                          },
                        );
                      },
                      children: List.generate(mutableWaypoints.length, (index) {
                        return ListTile(
                          key: ValueKey(mutableWaypoints[index]),
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            child: Text("${index + 1}",
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            mutableTitles[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                        );
                      })))
            ],
          ),
        );
      }),
      confirm: TextButton(
          onPressed: () {
            onReorderCompleted(mutableWaypoints, mutableTitles);
            Get.back();
          },
          child: const Text("save")),
      cancel: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("cancel")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              _showRouteList(context);
            },
            child: const Text("adjust route"),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            YellowButton(
              onPressed: () {
                Get.toNamed("/link_route", arguments: {
                      "waypointsTitles": waypointsTitles,
                      "routeDetails": routeDetails, 
                    },);
              },
              iconUrl: 'lib/images/plan_save.svg',
              label: "Link Route",
            ),
            YellowButton(
              onPressed: () {
                Get.toNamed("/list");
              },
              iconUrl: 'lib/images/Card.svg',
              label: "Buy Tickets",
            ),
          ]),
          const SizedBox(height: 12),
        ]));
  }
}
