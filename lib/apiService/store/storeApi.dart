import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopapp/shared/components/constants.dart';
import '../../shared/network/remote/cachehelper.dart';



 Future getStoresApi({latitude,longitude})async{
  String access_token = Cachehelper.getData(key: "token");
  http.Response response = await http.get(
       Uri.parse('https://www.api.canariapp.com/v1/client/stores?latitude=${latitude==null?27.149890:latitude}&longitude=${longitude==null?-13.199970:longitude}&all=true&locale=$lg&category=${service_type}'
       ),
    headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
   );
  // https://www.api.canariapp.com/v1/client/stores?category=${service_type}&include=menus.products.modifierGroups.products,menus.products&latitude=${latitude}&longitude=${longitude}&all=true&locale=ar
   var responsebody = jsonDecode(response.body);




  return responsebody;
  }

 Future getStoreApi({slug,latitude,longitude})async{
  String access_token = Cachehelper.getData(key: "token");
   http.Response response = await http
    .get(
       Uri.parse('https://www.api.canariapp.com/v1/client/stores/${slug}?include=menus.products.modifierGroups.products,menus.products&latitude=${latitude}&longitude=${longitude}&locale=${lg}'),
    headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
   );

   var responsebody = jsonDecode(response.body);


    return responsebody;
  }

  Future getCategorieApi()async{
   http.Response response = await http
    .get(Uri.parse('https://www.api.canariapp.com/v1/client/categories?&locale=${lg}'));
    var responsebody = jsonDecode(response.body);
    return responsebody;
  }


  Future CheckoutApi(payload)async{
  http.Response response = await http.post(
     Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
     body:payload
  );
  var responsebody = jsonDecode(response.body);
  return responsebody;
 }

 Future FilterDataApi({latitude,longitude,elements})async{
 String access_token = Cachehelper.getData(key: "token");
  var url = 'https://api.canariapp.com/v1/client/stores?filter[categories.translations.name]=${elements}&latitude=${latitude==null?27.149890:latitude}&longitude=${longitude==null?-13.199970:longitude}&all=true&locale=$lg';
 http.Response response = await http
     .get(Uri.parse(url),
  headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
 );
 print(url);
 var responsebody = jsonDecode(response.body);
 return responsebody;
}
  Future OfferDataApi({latitude,longitude,offerId})async{
 String access_token = Cachehelper.getData(key: "token");
  var url = 'https://api.canariapp.com/v1/client/offers/${offerId}?latitude=${latitude==null?27.149890:latitude}&longitude=${longitude==null?-13.199970:longitude}&locale=$lg';
 http.Response response = await http
     .get(Uri.parse(url),
  headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
 );
 var responsebody = jsonDecode(response.body);
 return responsebody;
}

  Future getStoresNearApi({latitude,longitude})async{
  String access_token = Cachehelper.getData(key: "token");
  http.Response response = await http.get(
  Uri.parse('https://api.canariapp.com/v1/client/stores/nearby?latitude=${latitude==null?27.149890:latitude}&longitude=${longitude==null?-13.199970:longitude}&all=true&locale=${lg}&category=${service_type}'
  ),
  headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
 );

 var responsebody = jsonDecode(response.body);

 return responsebody;
}
  Future getStoresPopularApi({latitude,longitude})async{
  String access_token = Cachehelper.getData(key: "token");
  http.Response response = await http.get(
  Uri.parse('https://api.canariapp.com/v1/client/stores/popular?latitude=${latitude==null?27.149890:latitude}&longitude=${longitude==null?-13.199970:longitude}&all=true&locale=${lg}&category=${service_type}'
  ),
  headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
 );

 var responsebody = jsonDecode(response.body);

 return responsebody;
}