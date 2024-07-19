import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:flutter/material.dart';

class MultipleForms extends StatefulWidget {
  const MultipleForms({Key? key}) : super(key: key);

  @override
  _MultipleFormsState createState() => _MultipleFormsState();
}

class _MultipleFormsState extends State<MultipleForms> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Forms Page'),
        backgroundColor: Colors.lightGreen,
        actions: [],
      ),
      body: Container(
        decoration: UiConstants.backgroundGradient,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.leave_bags_at_home,
                              color: Colors.red), // Change the icon as needed
                          Text(
                            'Leave Form',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      )),
                  SizedBox(width: 16.0),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.perm_device_information,
                              color: Colors.red),
                          Text('Permission Form',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
