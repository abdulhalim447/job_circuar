import 'package:flutter/material.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disclaimer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disclaimer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jobs Notice BD is an independent, private job information app.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app is NOT affiliated with, authorized by, or endorsed by the Government of Bangladesh or any government agency.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'We do NOT represent any government entity and do NOT provide or facilitate government services.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'All job information is collected from publicly available sources such as official government websites, public notices, and verified news publications.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Users are advised to verify all information from the respective official sources before applying.',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'img/banner.jpg',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
