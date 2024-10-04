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
      'profilePic':
          'https://martech.org/wp-content/uploads/2016/04/ss-rating-review-stars.jpg',
      'rating': 4.8,
      'review':
          'This app is so easy to use! The interface is intuitive, and everything just flows smoothly. The animations are a nice touch as well.',
      'date': 'Sep 15, 2024',
    },
    {
      'name': 'Jane Smith',
      'profilePic':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0dptC1sXTv9XCytLR_lsBjFtouv6EYEFYqg&s',
      'rating': 5.0,
      'review':
          'Absolutely love the user interface. It looks stunning, and the performance is excellent. The developers clearly paid attention to detail.',
      'date': 'Sep 10, 2024',
    },
    {
      'name': 'Michael Brown',
      'profilePic':
          'https://martech.org/wp-content/uploads/2016/04/ss-rating-review-stars.jpg',
      'rating': 4.5,
      'review':
          'The app is built with great technology. I appreciate how responsive it is. The design elements are modern and very attractive!',
      'date': 'Sep 5, 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('App Reviews'),
        backgroundColor: Colors.blueAccent,
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
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(review['profilePic']),
                          radius: 30.0,
                        ),
                        SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.0),
                            _buildStarRating(review['rating']),
                            SizedBox(height: 6.0),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      review['review'],
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
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
          return Icon(Icons.star, color: Colors.amber, size: 20.0);
        } else if (index < rating + 0.5) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20.0);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20.0);
        }
      }),
    );
  }
}
