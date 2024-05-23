import 'package:flutter/material.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key key}) : super(key: key);

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final String url = "https://superappcanari.com/privacy.html";
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          lg=='ar'?'سياسة الخصوصية':"Politique de confidentialité",
          style: TextStyle(
              fontSize: 17,
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body:Stack(
        children: [
          WebView(
            initialUrl:lg=='ar'?url:'https://superappcanari.com/privacy_fr.html',
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color:AppColor),
            ),
        ],
      ),
    );
  }
}
