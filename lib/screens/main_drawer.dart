import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:share_plus/share_plus.dart';

import 'package:job_circular/screens/appsettings.dart';
import 'package:job_circular/screens/favpage.dart';
import 'package:job_circular/screens/disclaimer.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(color: Colors.white),
            child: Image.asset('img/banner.jpg', fit: BoxFit.contain),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.green),
            title: const Text('Favourites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.green),
            title: const Text('App Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppSettingsPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.rule, color: Colors.green),
            title: const Text('Terms Of Service'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse('https://jobsnoticebd.com/privacy-policy-app/'),
                );
              } catch (e) {
                await Fluttertoast.showToast(
                  msg: "Sorry! Cannot Launch This Url",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.green),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse('https://jobsnoticebd.com/privacy-policy-app/'),
                );
              } catch (e) {
                await Fluttertoast.showToast(
                  msg: "Sorry! Cannot Launch This Url",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
            title: const Text('Privacy Policy'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.web, color: Colors.green),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(Uri.parse('https://jobsnoticebd.com/'));
              } catch (e) {
                await Fluttertoast.showToast(
                  msg: "Sorry! Cannot Launch This Url",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
            title: const Text('Visit Website'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.green),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisclaimerPage()),
              );
            },
            title: const Text('Disclaimer'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('Message Us'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse('https://wa.me/8801625971309'),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                // Ignore
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text('Share App'),
            onTap: () {
              Navigator.pop(context);
              Share.share(
                'Download the best jobs app: https://play.google.com/store/apps/details?id=com.jobs_notice_bd.app',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.green),
            title: const Text('Rate Now'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.jobs_notice_bd.app',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                // Ignore
              }
            },
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
            child: Text(
              'Contact Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.green),
            title: const Text('mdmohasinislam9001@gmail.com'),
            subtitle: const Text('Email Us'),
            onTap: () async {
              Navigator.pop(context);
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'mdmohasinislam9001@gmail.com',
              );
              try {
                await launchUrl(emailLaunchUri);
              } catch (e) {
                // Ignore
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('+8801625971309'),
            subtitle: const Text('WhatsApp/Phone'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse('https://wa.me/8801625971309'),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                // Ignore
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.facebook, color: Colors.green),
            title: const Text('Facebook Page'),
            subtitle: const Text('jobsnoticebdcom'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await launchUrl(
                  Uri.parse('https://www.facebook.com/jobsnoticebdcom'),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                // Ignore
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: const Text('Uttom Hazi Para Hazir Hat'),
            subtitle: const Text('Rangpur 5400, Bangladesh'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
