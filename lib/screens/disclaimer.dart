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
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 30),
                        const SizedBox(width: 10),
                        const Text(
                          '⚠️ DISCLAIMER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Jobs Notice BD is an independent private information service. This app is NOT affiliated with, authorized by, or endorsed by the Government of Bangladesh or any government agency. All job information is manually curated from publicly available sources and republished via jobsnoticebd.com for informational purposes only.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 30),
                    const Text(
                      'Jobs Notice BD একটি স্বতন্ত্র ও বেসরকারি তথ্য সেবামূলক অ্যাপ্লিকেশন। এই অ্যাপটি বাংলাদেশ সরকার বা অন্য কোনো সরকারি সংস্থার সাথে কোনোভাবেই যুক্ত নয় বা তাদের দ্বারা অনুমোদিত নয়। সকল চাকুরির তথ্য প্রকাশ্য উৎস থেকে সংগ্রহ করে jobsnoticebd.com এর মাধ্যমে শুধুমাত্র তথ্য পরিবেশনের জন্য এখানে পুনরায় প্রকাশ করা হয়।',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Opacity(
              opacity: 0.6,
              child: Image.asset(
                'img/banner.jpg',
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'www.jobsnoticebd.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
