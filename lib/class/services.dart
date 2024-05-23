import 'dart:convert';

import 'package:http/http.dart' as http;

import '../shared/components/constants.dart';

class Services{
  var mylist;
  Map<String, dynamic> placesList = {};


  // Future<void> getSuggestion(String input)async{
  //   String KPLACES_API_KEY = "AIzaSyCXgGsPTHMZ9PJ6nt-3bcAaqdGCyCrFDzE";
  //   String baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  //   String request = "$baseURL?input=$input&key=$KPLACES_API_KEY&sessiontoken=$sessionToken";
  //   var response = await http.get(Uri.parse(request));
  //   print(response.body.toString());
  //   if(response.statusCode == 200){
  //     placesList = jsonDecode(response.body.toString());
  //     print(placesList);
  //   }else{
  //     throw Exception('Failed to load data');
  //   }
  // }



}


