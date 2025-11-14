import 'package:flutter/material.dart';
import 'package:job_circular/screens/allposts.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        final categories = categoriesProvider.categories;

        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('img/banner.jpg'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (_, i) {
                      final category = categories[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllPosts(categoryId: category['id'], categoryName: category['name']),
                            ),
                          );
                        },
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              'img/${category['id']}.jpg',
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(category['icon'] ?? Icons.work, size: 50, color: Colors.blue),
                                    SizedBox(height: 8),
                                    Text(
                                      category['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
