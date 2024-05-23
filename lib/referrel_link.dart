import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;

class ReferralPage extends StatefulWidget {
  @override
  _ReferralPageState createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String referralCode = '';

  void generateLink()async{
    print('isLoading');
    var Jsondata = {
      "dynamicLinkInfo": {
        "domainUriPrefix": "https://canari.page.link",
        "link": "https://yourapp.com/invite?id=12345",
        "androidInfo": {
          "androidPackageName": "com.canari.app",
        },
        "iosInfo": {
          "iosBundleId": "com.canari.app",
        },
        "navigationInfo": {
          "enableForcedRedirect": false
        },
        "suffix": {
          "option": "SHORT"
        }
      }
    };
    var key = 'AIzaSyB4ANuPNjUpLjpnn100wnUIVnKTDKD9yT4';
 await http.post(
        Uri.parse('https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${key}'),
        headers:{'Content-Type':'application/json','Accept':'application/json',},
        body:jsonEncode(Jsondata)
    ).then((value){
   print('succes');
   var responsebody = jsonDecode(value.body);
  print(responsebody);
 }).catchError((err){
   print('error');
   print(err);
 });
  }

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  Future<void> _initDynamicLinks() async {
    // Listen for incoming dynamic links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        // Extract referral code from the deep link
        referralCode = deepLink.queryParameters['id'];
        print('Referral Code: $referralCode');
        setState(() {}); // Update the UI with the referral code
      }
    }, onError: (error) {
      print('Dynamic Link Error: $error');
    });

    // Check if the app was opened via a dynamic link
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      // Extract referral code from the deep link
      referralCode = deepLink.queryParameters['id'];
      print('Referral Code: $referralCode');
      setState(() {}); // Update the UI with the referral code
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referral Page'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(onPressed: (){
              generateLink();
            }, child:Text('generate Link')),
            Text('Referral Code: $referralCode'),
          ],
        ),
      ),
    );
  }
}