import 'package:flutter/material.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web extends StatefulWidget {
  final url;
  final name;
  const Web({Key key,this.url,this.name}) : super(key: key);

  @override
  State<Web> createState() => _WebState();
}

class _WebState extends State<Web> {
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar:AppBar(
        backgroundColor:AppColor,
         elevation:0,
         centerTitle:true,
         title: Text("${widget.name}"),
      ),
      body:Stack(
        children: [
          WebView(
            initialUrl:'${widget.url}',
            javascriptMode:JavascriptMode.unrestricted,
            onPageStarted:(urlStart) {
              setState(() {

              });
            },
            onPageFinished: (urlStart) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          if(_isLoading)
            Center(
              child:CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
