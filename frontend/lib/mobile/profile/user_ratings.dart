import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/models/rating.dart';
import 'package:intl/intl.dart';

class UserRatingsScreen extends StatelessWidget {
  static const routeName = '/ratings';

  static Future<void> navigateTo(BuildContext context,
      {required List<Rating> ratings}) {
    return Navigator.of(context).pushNamed(routeName, arguments: ratings);
  }

  final List<Rating> ratings;

  const UserRatingsScreen({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('home.profile.ratings')),
      ),
      body: ListView.builder(
        itemCount: ratings.length,
        itemBuilder: (ctx, index) {
          final rating = ratings[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black12,
                          child: Text(
                            rating.user.firstName[0].toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xFF131141),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${rating.user.firstName} ${rating.user.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(
                                DateTime.parse(rating.createdAt),
                              ),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          Icons.star,
                          color: starIndex < rating.rating!
                              ? Colors.amber
                              : Colors.grey,
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(rating.comment!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
