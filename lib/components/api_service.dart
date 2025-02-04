import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://cloud.mp.trenord.it";
  static const String _apiKey = "Y8X4IMtQBhmFIQYvOBmrr6TWZYN4jooE";

  static Future<List<Map<String, dynamic>>> getTrainRoutes({
    required String origin,
    required String destination,
    required String departureDate,
    String? departureTime,
  }) async {
    String urlString =
        "$_baseUrl/hafas?orig=$origin&dest=$destination&departure_date=$departureDate";
    if (departureTime != null && departureTime.isNotEmpty) {
      urlString += "&departure_hour=$departureTime";
    }

    final Uri url = Uri.parse(urlString);

    try {
      final response = await http.get(url, headers: {"secret": _apiKey});
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          List<Map<String, dynamic>> trainRoutes = [];

          for (var journey in data) {
            if (journey.containsKey("journey_list") &&
                journey["journey_list"].isNotEmpty) {
              var firstStep = journey["journey_list"][0]; 

              trainRoutes.add({
                "departureTime": journey["dep_time"] ?? "N/A",
                "arrivalTime": journey["arr_time"] ?? "N/A",
                "duration": journey["duration"] ?? "N/A",
                "changes": int.tryParse(journey["change"].toString()) ?? 0,
                "departureStation":
                    journey["dep_station"]?["station_ori_name"] ?? origin,
                "arrivalStation":
                    journey["arr_station"]?["station_ori_name"] ?? destination,
                "trainOperator":
                    firstStep["train"]?["train_operator"] ?? "Unknown",
              });
            }
          }
          return trainRoutes;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
