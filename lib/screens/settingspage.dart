import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_circular/screens/appsettings.dart';
import 'package:job_circular/screens/favpage.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('img/banner.jpg'),
        Divider(),
        ListTile(
          leading: Icon(Icons.favorite_border, color: Colors.green),
          title: Text('Favourites'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FavPage()));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.green),
          title: Text('App Settings'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AppSettingsPage()));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.rule, color: Colors.green),
          title: Text('Terms Of Service'),
          onTap: () async {
            try {
              await launchUrl(Uri.parse('https://jobsnoticebd.com/privacy-policy/'));
            } catch (e) {
              await Fluttertoast.showToast(
                msg: "Sorry! Cannot Launch This Url",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.policy, color: Colors.green),
          onTap: () async {
            try {
              await launchUrl(Uri.parse('https://jobsnoticebd.com/privacy-policy/'));
            } catch (e) {
              await Fluttertoast.showToast(
                msg: "Sorry! Cannot Launch This Url",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          title: Text('Privacy Policy'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.web, color: Colors.green),
          onTap: () async {
            try {
              await launchUrl(Uri.parse('https://jobsnoticebd.com/'));
            } catch (e) {
              await Fluttertoast.showToast(
                msg: "Sorry! Cannot Launch This Url",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          title: Text('Visit Website'),
        ),
      ],
    );
  }
}
