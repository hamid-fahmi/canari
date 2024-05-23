import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
 
class DynamicLinkProvider{

Future<String>createLink(String refCode)async{
  final String url = "https://com.canari.app?ref=${refCode}";
  final DynamicLinkParameters parameters = DynamicLinkParameters(
      androidParameters: AndroidParameters(
        packageName:"com.canari.app",minimumVersion: 0
      ),
      iosParameters: IOSParameters(
        bundleId:'com.canari.app',
        minimumVersion:"0"
      ),
      link:Uri.parse(url),uriPrefix:"https://canari.page.link");
  final FirebaseDynamicLinks link = await FirebaseDynamicLinks.instance;
  final refLink = await link.buildShortLink(parameters);
  return refLink.shortUrl.toString();
}

initDynamicLink()async{
  final instanceLink = await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = instanceLink.link;
  if(deepLink!=null){
   print(deepLink);
   print('come from link');
  }else{
    print('this man come from play-tore');
  }
}

}