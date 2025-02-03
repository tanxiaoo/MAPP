import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/yellow_button.dart';
import '../const.dart';
import 'package:intl/intl.dart';

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

  List<int> availableDates = [];
  List<String> mergeDates = [];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _initializeDates();
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
        _initializeDates();
      });
    }
  }

  void _initializeDates() {
    availableDates = List.generate(
      selectedDateRange!.end.difference(selectedDateRange!.start).inDays + 1,
      (i) => selectedDateRange!.start.add(Duration(days: i)).day,
    );
    mergeDates.clear(); // 清空已合并的日期
    setState(() {});
  }

  void _mergeDates(int start, int end) {
    availableDates.removeWhere((d) => d >= start && d <= end); // ✅ 移除单独日期
    mergeDates.add("$start-$end"); // ✅ 添加合并的日期范围
    setState(() {});
  }

  void _splitDateRange(String range) {
    List<int> parts = range.split("-").map(int.parse).toList();
    availableDates.addAll(List.generate(
        parts[1] - parts[0] + 1, (i) => parts[0] + i)); // ✅ 重新添加单独日期
    mergeDates.remove(range); // ✅ 从合并列表中移除
    availableDates.sort(); // ✅ 保证日期顺序
    setState(() {});
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
        body: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                Text("When do you want to visit?"),
                GestureDetector(
                  onTap: _selectedDateRange,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        Text(
                          selectedDateRange == null
                              ? "Select travel dates"
                              : "${DateFormat("EEE, d MMM").format(selectedDateRange!.start)} - "
                                  "${DateFormat("EEE, d MMM").format(selectedDateRange!.end)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    /// **合并后的日期标签**（双击拆分）
                    for (String range in mergeDates)
                      Draggable<String>(
                        data: range,
                        feedback: _dateBox(range, isDragging: true),
                        child: GestureDetector(
                            onDoubleTap: () => _splitDateRange(range),
                            child: _dateBox(range)), // ✅ 双击拆分
                      ),

                    /// **单独的日期标签**（拖动合并）
                    for (int date in availableDates)
                      Draggable<int>(
                        data: date,
                        feedback: _dateBox(date.toString(), isDragging: true),
                        child: DragTarget<int>(
                          onAccept: (draggedDate) =>
                              _mergeDates(draggedDate, date), // ✅ 拖动合并日期
                          builder: (context, candidateData, rejectedData) =>
                              _dateBox(date.toString()),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: widget.waypointsTitles.length * 2 - 1,
                  itemBuilder: (context, index) {
                    if (index.isEven) {
                      // attractin info
                      int actualIndex = index ~/ 2;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue,
                          child: Text(
                            "${actualIndex + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          widget.waypointsTitles[actualIndex],
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      int routeIndex = (index - 1) ~/ 2;
                      String routeKey = "${routeIndex}_${routeIndex + 1}";
                      List transportDetails =
                          widget.routeDetails[routeKey] ?? [];

                      return transportDetails.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    transportDetails.map<Widget>((detail) {
                                  bool isWalking =
                                      detail['mode'].toLowerCase() == "walking";

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _getTransportIcon(detail['mode']),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "${detail['mode']}${detail['line'].isNotEmpty ? ' - ${detail['line']}' : ''}", // ✅ 交通方式 + 线路
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
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
                                          "📍 ${detail['departure']} → ${detail['arrival']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox();
                    }
                  },
                ))
              ],
            )),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            YellowButton(
              onPressed: () {
                Get.toNamed("/list");
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
        ));
  }

  Widget _getTransportIcon(String mode) {
    switch (mode.toLowerCase()) {
      case "walking":
        return const Icon(Icons.directions_walk, color: Colors.blue);
      case "bus":
        return const Icon(Icons.directions_bus, color: Colors.orange);
      case "train":
        return const Icon(Icons.train, color: Colors.red);
      case "subway":
        return const Icon(Icons.subway, color: Colors.purple);
      case "tram":
        return const Icon(Icons.tram, color: Colors.green);
      case "ferry":
        return const Icon(Icons.directions_boat, color: Colors.teal);
      default:
        return const Icon(Icons.directions, color: Colors.grey);
    }
  }

  Widget _dateBox(String text, {bool isDragging = false}) => Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isDragging ? Colors.redAccent.withOpacity(0.7) : Colors.redAccent, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.black54,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                DateFormat("EEE, d MMM").format(selectedDate),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => selectedDate = DateTime.now()),
              child: Text(
                "Today",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedDate.day == DateTime.now().day
                        ? Colors.orange
                        : Colors.grey),
              ),
            ),
            const Text(
              "|",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            GestureDetector(
              onTap: () => setState(() =>
                  selectedDate = DateTime.now().add(const Duration(days: 1))),
              child: Text(
                "Tommorrow",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedDate.day ==
                            DateTime.now().add(const Duration(days: 1)).day
                        ? Colors.orange
                        : Colors.grey),
              ),
            )
          ],
        )
      ],
    );
  }
}
