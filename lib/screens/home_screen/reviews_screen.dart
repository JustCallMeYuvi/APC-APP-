import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'John Cena',
      'profilePic': 'https://via.placeholder.com/150',
      'rating': 4.5,
      'review':
          'The Apache RunBoost shoes are incredibly comfortable and great for long-distance running. Highly recommended for athletes!',
      'date': 'Sep 15, 2024',
      'shoeModel': 'Apache RunBoost',
      'shoeImage': 'https://via.placeholder.com/100',
    },
    {
      'name': 'Jane Smith',
      'profilePic': 'https://via.placeholder.com/150',
      'rating': 5.0,
      'review':
          'Amazing fit and support! I love the Apache MaxStride sneakers for my workouts. The design is top-notch too!',
      'date': 'Sep 10, 2024',
      'shoeModel': 'Apache MaxStride',
      'shoeImage': 'https://via.placeholder.com/100',
    },
    {
      'name': 'Michael Brown',
      'profilePic': 'https://via.placeholder.com/150',
      'rating': 4.0,
      'review':
          'The Apache FlexiWalk shoes are very comfortable for casual use, though I wish they had more color options.',
      'date': 'Sep 5, 2024',
      'shoeModel': 'Apache FlexiWalk',
      'shoeImage': 'https://via.placeholder.com/100',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Reviews'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: UiConstants.backgroundGradient,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(review['profilePic']),
                          radius: 24.0,
                        ),
                        SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            _buildStarRating(review['rating']),
                            SizedBox(height: 4.0),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          review['shoeImage'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['shoeModel'],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                review['review'],
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating) {
          return Icon(Icons.star, color: Colors.amber, size: 16.0);
        } else if (index < rating + 0.5) {
          return Icon(Icons.star_half, color: Colors.amber, size: 16.0);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 16.0);
        }
      }),
    );
  }
}
