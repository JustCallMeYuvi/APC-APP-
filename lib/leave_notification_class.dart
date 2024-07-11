// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class HolidayService {
//   static Future<Map<String, dynamic>?> fetchHolidayDetails(String empNo) async {
//     try {
//       // Construct API URL
//       String apiUrl =
//           'http://10.3.0.70:9040/api/Flutter/GetAH_HOLIDAYDetailsss?empNo=$empNo';

//       // Make GET request
//       var response = await http.get(Uri.parse(apiUrl));
//       print('${apiUrl}');

//       // Check if request was successful
//       if (response.statusCode == 200) {
//         // Parse JSON response
//         String responseBody = response.body;

//         // Check if responseBody is empty or contains only '[]'
//         if (responseBody.trim().isNotEmpty && responseBody.trim() != '[]') {
//           // Decode the JSON response
//           var responseJson = jsonDecode(responseBody);

//           // Check if responseJson is a list and has elements
//           if (responseJson is List && responseJson.isNotEmpty) {
//             // Extract required fields from the first object in the array
//             var startDate = responseJson[0]['START_DATE'];
//             var endDate = responseJson[0]['END_DATE'];
//             var holidayQty = responseJson[0]['HOLIDAY_QTY'];

//             return {
//               'startDate': startDate,
//               'endDate': endDate,
//               'holidayQty': holidayQty,
//             };
//           } else {
//             print('Holiday details empty or not available.');
//           }
//         } else {
//           print('Holiday details empty or not available.');
//         }
//       } else {
//         // Handle other status codes (e.g., 404, 500)
//         print('Failed to fetch holiday details: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle potential errors such as network errors
//       print('Error fetching holiday details: $e');
//     }
//     return null;
//   }
// }
