import 'dart:convert';

import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HeaderWidget extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  const HeaderWidget({
    super.key,
    required this.size,
    required this.userData,
  });

  final Size size;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  List<GetEmpDetails> empDetailsList = [];
  @override
  void initState() {
    super.initState();
    fetchData(widget.userData.empNo);
  }

  // Future<void> fetchData(String empNo) async {
  //   // final url = Uri.parse('http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=$empNo');
  //   final url = Uri.parse(
  //       'http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=${widget.userData.empNo}');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonResponse = json.decode(response.body);

  //       // Debug: Print the raw response body
  //       print('Response body: ${response.body}');

  //       // Debug: Print the parsed JSON data
  //       jsonResponse.forEach((data) {
  //         print('Parsed JSON item: $data');
  //       });

  //       setState(() {
  //         empDetailsList =
  //             jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

  //         // Debug: Print the list of empDetailsList
  //         empDetailsList.forEach((detail) {
  //           print(
  //               'Emp Detail: ${detail.empNo}, ${detail.empName}, ${detail.deptName}, ${detail.position}');
  //         });
  //       });
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //       // Handle error case, show error message or retry logic
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //     // Handle error case, show error message or retry logic
  //   }
  // }

// below is 9042 api
  Future<void> fetchData(String empNo) async {
    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=${widget.userData.empNo}');

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=${widget.userData.empNo}');

    print('URL ${url}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Debug: Print the raw response body
        print('Response body: ${response.body}');

        // Debug: Print the parsed JSON data
        jsonResponse.forEach((data) {
          print('Parsed JSON item: $data');
        });

        setState(() {
          empDetailsList =
              jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

          // Debug: Print the list of empDetailsList
          empDetailsList.forEach((detail) {
            // print(
            //     'Emp Detail: ${detail.empNo}, ${detail.empName}, ${detail.deptName}, ${detail.position}');
            print(
                'Emp Detail: ${detail.emPNo}, ${detail.emPName}, ${detail.depTName}, ${detail.position}');
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        // Handle error case, show error message or retry logic
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error case, show error message or retry logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: "Hello ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
                children: [
                  // TextSpan(
                  //   text: "User!",
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: 22,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  TextSpan(
                    text: empDetailsList.isNotEmpty
                        ? empDetailsList.first.emPName
                        : 'User',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Welcome to Apache App",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
        // Container(
        //   height: 52,
        //   width: 52,
        //   decoration: const BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //   ),
        //   child: UiConstants.image(
        //     // path: ImagePath.flutterBoy,

        //     path: ImagePath.apacheLogo,
        //   ),
        // ),
        Container(
          height: 52,
          width: 52,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: UiConstants.image(
              path: ImagePath.apacheIcon,
            ),
          ),
        ),
      ],
    );
  }
}
