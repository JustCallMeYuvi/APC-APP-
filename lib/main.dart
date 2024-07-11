import 'package:animated_movies_app/app.dart';
import 'package:animated_movies_app/auth_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(
  //   const App(),
  // );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Create AuthProvider instance
      child: const App(),
    ),
  );
}

// import 'package:animated_movies_app/app.dart';
// import 'package:animated_movies_app/leave_notification_class.dart';

// import 'package:flutter/widgets.dart';
// import 'package:workmanager/workmanager.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize WorkManager
//   Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(
//     const App(),
//   );
// }

// void callbackDispatcher() {
//   // Define _fetchHolidayDetails here or move it to the top of the file
//   Future<void> _fetchHolidayDetails(String empNo) async {
//     await HolidayService.fetchHolidayDetails(empNo);
//   }

//   Workmanager().executeTask((task, inputData) async {
//     await _fetchHolidayDetails(inputData!['empNo']);
//     return Future.value(true);
//   });
// }
