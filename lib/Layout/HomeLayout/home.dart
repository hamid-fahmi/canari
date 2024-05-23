import 'dart:async';
import 'package:another_stepper/dto/stepper_data.dart';
import 'package:buildcondition/buildcondition.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/HomeLayout/account.dart';
import 'package:shopapp/Layout/HomeLayout/searchStore.dart';
import 'package:shopapp/Layout/HomeLayout/selectAddres.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:shopapp/widgets/categoriesWidget.dart';
import 'package:shopapp/widgets/store.dart';
import 'package:shopapp/widgets/storeGridl.dart';
import 'package:shopapp/widgets/storeList.dart';
import '../../modules/pages/StorePage/store_page.dart';
import '../../modules/pages/Order/checkout_page.dart';
import '../../modules/pages/Static/filterPage.dart';
import '../../modules/pages/Order/myordersPage.dart';
import '../../modules/pages/Order/order.dart';
import '../../shared/network/remote/cachehelper.dart';
import '../../widgets/slidersWidget.dart';
import 'package:intl/intl.dart';

import 'layoutScreen.dart';

Future<void>firebaseMessagingBackgroundHandler(RemoteMessage message,)async{
  if (message.notification!=null) {
    print('${message.notification.body}');
  }
}

class Home extends StatefulWidget {
  final String myLocation;
  final double latitude;
  final double longitude;
  final String category;
  const Home({Key key,this.myLocation,this.latitude,this.longitude,this.category}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double lat = Cachehelper.getData(key: "latitude");
  String language = Cachehelper.getData(key:"langugeCode");
  int activeIndex = 2;
  Future<Position> getLocation() async {
     if(lat==null) {
       Position position = await Geolocator.getCurrentPosition(
           desiredAccuracy: LocationAccuracy.low).then((value) {
         Cachehelper.sharedPreferences.setDouble('latitude',
             value.latitude);
         Cachehelper.sharedPreferences.setDouble('longitude',
             value.longitude);
         latitude = value.latitude;
         longitude = value.longitude;
         return value;
       });
       return position;
     }

  }

  Future getPostion()async{
    bool services;
    services = await Geolocator.isLocationServiceEnabled();
    print(services);
  }


  HashSet selectFilters = new HashSet();

  var fbm = FirebaseMessaging.instance;
  String fcmtoken='';


  bool isCategoriesLoading = false;

  List Categories = [];

  Future<void> GetCategories() async{
    isCategoriesLoading = false;
    String access_token = Cachehelper.getData(key: "token");
    http.Response response = await http.get(Uri.parse('https://api.canariapp.com/v1/client/categories?type=${service_type}&locale=$lg'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value){
      var responsebody = jsonDecode(value.body);
      setState(() {
        isCategoriesLoading = true;
        Categories = responsebody;
      });
    }).catchError((onError){

    });
    return response;
  }



  PaymentAvibalty() async {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 60),
        minimumFetchInterval: Duration(seconds: 1)
    ));
    await remoteConfig.fetchAndActivate();
    payment_by_card = remoteConfig.getBool('isPaymentactive');
    setState(() {

    });
  }
  GeolocatorPlatform geolocator = GeolocatorPlatform.instance;

  bool locationServiceEnabled = false;
  LocationPermission permission;


  @override
  void initState(){
     checkLocationStatus();
     GetCategories();
     PaymentAvibalty();
     FirebaseMessaging.instance.getInitialMessage();
     fbm.getToken().then((token){
       print('-------------------------------------');
       printFullText(token.toString());
       print('-------------------------------------');
       fcmtoken = token;

     });
    super.initState();
  }

  Stream<bool> checkLocationStatus() async* {
    bool serviceEnabled;
    LocationPermission status;

    // Check if location services are enabled
    serviceEnabled = await geolocator.isLocationServiceEnabled();

    // Get location permission status
    status = await geolocator.checkPermission();

    setState(() {
      locationServiceEnabled = serviceEnabled;
      permission = status;
    });
    
  }
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      return false;
    }
    return true;

  }



   bool islist = true;
   String text ='';
   Map json = {};
   var price;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer timer;
  bool ishow = false;

  

  @override
  Widget build(BuildContext context) {

     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
     FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification!=null){
        Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
        json["data"] = jsonMap;
        printFullText(jsonMap.toString());
        // navigateTo(context,Order(
        //   order:json,
        //   route: 'myorders',
        // ));
      }
     });

     double latitud = Cachehelper.getData(key: "latitude");
     double longitud = Cachehelper.getData(key: "longitude");
     String MyLocation = Cachehelper.getData(key: "myLocation");
     String access_token = Cachehelper.getData(key: "token");


     return BlocProvider(
      create: (BuildContext context) => StoreCubit()..
      getStoresData(latitude: latitud==null?27.149890:latitud,longitude: longitud==null?-13.199970:longitud)..Myorders()..getStoresNear(latitude: latitud==null?27.149890:latitud,longitude: longitud==null?-13.199970:longitud)..getConfig(),
      child: BlocConsumer<StoreCubit, ShopStates>(
        listener: (context, state) {
          if(state is MyorderSucessfulState){
            navigateTo(context,Order(
              order:state.order,
              route: 'myorders',
            ));
          }
          if(state is GetFilterDataLoadingState){
            Navigator.pop(context);
            setState(() {
              navigateTo(context, FilterPage(text: text,Categories:Categories));
            });
          }
        },
        builder: (context, state) {
          var cubit = StoreCubit.get(context);

          cubit.stores.sort((a, b) => b["rate"].compareTo(a["rate"]));

          cubit.stores.sort((a, b) {
            // Sort open stores before closed stores
            if (a["is_open"] == true && b["is_open"] == false) {
              return -1;
            } else if (a["is_open"] == false && b["is_open"] == true) {
              return 1;
            }
            // If both stores have the same open status, sort them alphabetically by name
            return b["rate"].compareTo(a["rate"]);
          });

          cubit.storesNear.sort((a, b) => b["rate"].compareTo(a["rate"]));

          cubit.storesNear.sort((a, b) {
            // Sort open stores before closed stores
            if (a["is_open"] == true && b["is_open"] == false) {
              return -1;
            } else if (a["is_open"] == false && b["is_open"] == true) {
              return 1;
            }
            // If both stores have the same open status, sort them alphabetically by name
            return b["rate"].compareTo(a["rate"]);
          });



          var restaurantsWithDiscount = cubit.stores.where((restaurant) {
            List<dynamic> offers = restaurant['offers'];
            return offers.any((offer) => offer['type'] != "freeDeliveryFirstOrder");
          }).toList();

          restaurantsWithDiscount.sort((a, b) => b["rate"].compareTo(a["rate"]));

          restaurantsWithDiscount.sort((a, b) {
            // Sort open stores before closed stores
            if (a["is_open"] == true && b["is_open"] == false) {
              return -1;
            } else if (a["is_open"] == false && b["is_open"] == true) {
              return 1;
            }
            return b["rate"].compareTo(a["rate"]);
          });


          return StreamBuilder<bool>(
            stream:checkLocationStatus(),
            builder:(context,snapshot){
              return Scaffold(
                bottomNavigationBar:cubit.getCartItem() != 0
                    ?
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2,
                            spreadRadius: 1,
                            offset: Offset(0, 1))
                      ]),
                  height: 75,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 10),
                    child: GestureDetector(
                      onTap:() async {
                        if (dataService.itemsCart[0]['storeStatus']==false){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:Text(
                              DemoLocalization.of(context).getTranslatedValue('Vous_avez_commandé_dans_un_restaurant_fermé'),
                                  style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                             ),
                            duration: Duration(milliseconds: 2000),
                          ));
                          dataService.itemsCart.clear();
                          setState(() {

                          });
                        } else {
                          if (latitud != null){
                            var store = cubit.stores.where((e) =>e['name']==dataService.itemsCart[0]['storeName']).toList().first;
                            var totalPrice = await navigateTo(
                              context,CheckoutPage(
                              rout:service_type,
                              paymentMethods:store['payment_methods'],
                              service_fee:store['service_fee'],
                              delivery_price:store['delivery_price'],
                              olddelivery_price:store['delivery_price_old'],
                              store:store,
                            ));
                            setState(() {
                              totalPrice = price;
                            });
                          } else {
                            final changeAdress = await navigateTo(
                                context,
                                SelectAddres(
                                  routing: 'restaurantPage',
                                ));
                            setState(() {
                              if (changeAdress != null) {
                                MyLocation = changeAdress;
                              }
                            });
                          }
                        }},

                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColor,
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Row(
                                  children: [
                                    Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:BorderRadius.circular(5),
                                          color:cubit.getCartItem() == 0 ? Color.fromARGB(255, 253, 143, 135) : Color.fromARGB(255, 253, 106, 95),
                                        ),
                                        child: Center(
                                            child: Text(
                                              '${cubit.getCartItem()}',
                                              textAlign:
                                              TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ))),
                                    width(10),
                                    Text(
                                      DemoLocalization.of(context).getTranslatedValue('Voir_demande'),
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.w500,
                                          fontSize: 17,
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              Text(
                                '${cubit.getTotalPrice()} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                :SizedBox(
                  height:0,
                 ),
                appBar:peak_time_status=='full'?AppBar(backgroundColor: Colors.white,elevation: 0,toolbarHeight:2,):AppBar(
                  automaticallyImplyLeading: false,
                  elevation:0,
                  backgroundColor:Colors.white,
                  // leading: GestureDetector(
                  //     onTap: (){
                  //       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutPage(
                  //         latitude: latitud,
                  //         longitude: longitud,
                  //         myLocation: myLocation,
                  //       )),(route) => false);
                  //
                  //     },
                  //     child: Icon(Icons.arrow_back,color: Colors.black)),
                  title:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // InkWell(
                      // onTap: (){
                      //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                      //               latitude: latitud,
                      //               longitude: longitud,
                      //               myLocation: myLocation,
                      //             )),(route) => false);
                      //  },
                      //   child: Icon(Icons.arrow_back,color: Colors.black)),
                      MyLocation!=null?Expanded(
                        child:InkWell(
                            onTap: (){
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>SelectAddres(routing: 'homepage',)),(route) => false);
                            },
                          child: Row(
                            children:[
                              MyLocation.length<=30?Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.black,),),
                                    height(4),
                                    Text(
                                      MyLocation!=null? "${MyLocation}":'اختر موقع',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ):
                              Expanded(
                                child:Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.black,),),
                                      Text(
                                        MyLocation!=null? "${MyLocation}":'اختر موقع',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ):Expanded(
                        child: Row(
                          children:[
                            Icon(Icons.location_on,color: Colors.black),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.red,),),
                                  height(4),
                                  Text(
                                    MyLocation!=null? "${MyLocation}":DemoLocalization.of(context).getTranslatedValue('Choisissez_un_emplacement'),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        lg!='ar'?Padding(
                          padding:EdgeInsets.only(left:0,right:10),
                          child:Center(
                            child:IconButton(onPressed:(){
                              navigateTo(context,Account(routing: 'homepage',));
                            },
                                icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                          ),
                        ):Padding(
                          padding:EdgeInsets.only(left:0,right:0),
                          child:Center(
                            child:IconButton(onPressed:(){
                              navigateTo(context,Account(routing:'homepage'));
                            },
                                icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                          ),
                        ),

                      ],
                    )
                  ],
                ),
                backgroundColor:Colors.white,
                floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
                bottomSheet:snapshot.data==ConnectivityResult.none?buildNoNetwork():height(0),
                floatingActionButton:peak_time_status=='full'?SizedBox(height: 0,):cubit.isloading?
                cubit.myorders!=null && cubit.myorders.length>0 && cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                    .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&&e['status']!='failed'&& e['status']!='cancelled').toList().length!=0?FloatingActionButton.extended(
                    extendedPadding: EdgeInsetsDirectional.only(start: 7.0, end: 7.0) ,
                    backgroundColor: Colors.white,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onPressed: (){
                      if(cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                          .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&& e['status']!='failed'&& e['status']!='cancelled').toList().length==1){
                        cubit.Myorder(cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                            .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&& e['status']!='failed'&& e['status']!='cancelled').toList()[0]['order_ref']);
                        cubit.isload = false;
                      }else{
                        navigateTo(context,MyorderPage());
                      }
                    },
                      label:peak_time_status=='full'?SizedBox(height: 0):Row(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                    .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&& e['status']!='failed'&& e['status']!='cancelled').toList().length>0? Container(
                                    height: 35,width: 35,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color:Color.fromARGB(255, 253, 106, 95)),
                                    child:cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                        .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&& e['status']!='failed'&& e['status']!='cancelled').toList().length==1?ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:CachedNetworkImage(
                                          imageUrl: '${cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                              .where((e)=>e['status']!='delivered' && e['status']!='non-accepted'&& e['status']!='failed'&& e['status']!='cancelled').toList()[0]['store']['logo']}',
                                          placeholder: (context, url) =>
                                              Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                          imageBuilder: (context, imageProvider){
                                            return Container(
                                              decoration:BoxDecoration(
                                                image:DecorationImage(
                                                  image:imageProvider,
                                                  fit:BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          }
                                      ),

                                    ):Center(
                                      child: Text('${cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                          .where((e)=>e['status']!='delivered' && e['status']!='failed'&& e['status']!='cancelled').toList().length}',style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    )):height(0),
                                width(10),
                                Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    height(2),
                                    if(cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                        .where((e)=>e['status']!='delivered' && e['status']!='non-accepted' && e['status']!='failed' && e['status']!='cancelled').toList().length==1)
                                      Text('${cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                      .where((e)=>e['status']!='delivered' && e['status']!='non-accepted' && e['status']!='failed'&& e['status']!='cancelled').toList()[0]['store']['name']}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 11.5,color:Colors.black),),
                                    cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                        .where((e)=>e['status']!='delivered'  && e['status']!='non-accepted' && e['status']!='failed'&& e['status']!='cancelled').toList().length==1?height(2):height(8),
                                    cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                        .where((e)=>e['status']!='delivered'  && e['status']!='non-accepted' && e['status']!='failed'&& e['status']!='cancelled').toList().length>0?Column(
                                      children: [
                                        cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                            .where((e)=>e['status']!='delivered' && e['status']!='non-accepted' && e['status']!='failed'&& e['status']!='cancelled').toList().length==1?
                                        Text(status(cubit.myorders.where((element) => DateFormat('dd/MM/yyyy').format(DateTime.parse(element['created_at']))==DateFormat('dd/MM/yyyy').format(DateTime.now())).toList()
                                            .where((e)=>e['status']!='delivered' && e['status']!='non-accepted' && e['status']!='failed'&& e['status']!='cancelled').toList()[0]['status']),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 11.5,color:Color(0xFF25d366)),)
                                            :Text(DemoLocalization.of(context).getTranslatedValue('Voir_les_demandes'),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 11.5,color:Colors.black),),
                                      ],
                                    ):height(0),
                                  ],
                                ),
                              ],),
                          ],
                        ),
                        width(120),
                        IconButton(onPressed:(){

                        },icon:Icon(Icons.arrow_forward_ios,color:Colors.black,size:12))
                      ],
                    )
                ):height(0):height(0),
                body:peak_time_status=='full'?Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/burger.png',height:120,width:120),
                      height(20),
                      Text(DemoLocalization.of(context).getTranslatedValue('bienvenue'),style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                      ),),
                      height(20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Container(
                          child:Text(DemoLocalization.of(context).getTranslatedValue('peack'),style: TextStyle(
                              height: 2.5,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold
                          ),textAlign: TextAlign.center,),
                        ),
                      ),
                    ],
                  ),
                )
                    :SingleChildScrollView(
                     child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Padding(
                          padding: const EdgeInsets.only(left:10,right:20,bottom:0),
                          child: GestureDetector(
                            onTap: (){
                              navigateTo(context,SearchStore());
                            },
                            child:Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:Color(0xFFf3f4f5),
                              ),
                              height:40,
                              width:double.infinity,
                              child:Row(
                                children:[
                                  SizedBox(width: 15,),
                                  Icon(Icons.search,color: Color.fromARGB(255,98,98,98),size: 20),
                                  width(5),
                                  Text(DemoLocalization.of(context).getTranslatedValue('search_bymeal'),style: TextStyle(
                                      color: Color.fromARGB(255, 98, 98, 98),
                                      fontSize: 13
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        height(9),
                        SlidersWidget(selectFilters:selectFilters),
                        height(0),
                        location_alert? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             locationServiceEnabled!=true?Padding(
                               padding: const EdgeInsets.only(left:15,right:15,bottom: 5,top:5),
                               child:GestureDetector(
                                 onTap: (){
                                   handleLocationPermission().then((value){
                                     Geolocator.getCurrentPosition();
                                   });
                                 },
                                 child: Container(
                                     decoration:BoxDecoration(
                                         color:Color(0xFFe3e8ec),
                                         borderRadius: BorderRadius.circular(7)
                                     ),
                                     width:double.infinity,
                                     child:Column(
                                       crossAxisAlignment:CrossAxisAlignment.start,
                                       children: [
                                         Padding(
                                           padding: const EdgeInsets.only(right:20,left:20,top:15),
                                           child: Row(
                                             children: [
                                               CircleAvatar(
                                                 child: Icon(Icons.location_disabled_outlined,size:20),
                                                 minRadius: 15,
                                               ),
                                               width(10),
                                               Expanded(
                                                 child: Column(
                                                   crossAxisAlignment:CrossAxisAlignment.start,
                                                   children: [
                                                     Text(DemoLocalization.of(context).getTranslatedValue('enable_location_title'),
                                                       style: TextStyle(
                                                           color: Colors.black,
                                                           fontWeight: FontWeight.bold,
                                                           fontSize: 14),
                                                     ),
                                                     height(4),
                                                     Text(DemoLocalization.of(context).getTranslatedValue('enable_location_description'),
                                                       style: TextStyle(
                                                           color: Colors.black,
                                                           fontWeight: FontWeight.w400,
                                                           fontSize: 14),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ],),
                                         ),
                                         height(10),
                                         Padding(
                                           padding: const EdgeInsets.only(left:60,right:60,bottom: 15),
                                           child:Container(
                                               decoration:BoxDecoration(
                                                   color:Colors.white,
                                                   borderRadius: BorderRadius.circular(20)
                                               ),
                                               child:Padding(
                                                 padding:const EdgeInsets.only(left:20,right:20,top:10,bottom:10),
                                                 child:Text(DemoLocalization.of(context).getTranslatedValue('active_location'),style:TextStyle(fontWeight:FontWeight.bold),),
                                               )),
                                         )
                                       ],
                                     )
                                 ),
                               ),
                             ):height(0),
                           ],
                        ):height(0),
                        Categories.length>0?Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            title(text:DemoLocalization.of(context).getTranslatedValue('categoriy'),size: 16,color:Colors.black),
                          ],
                        ):height(0),
                        Categories.length>0?height(14):height(0),
                        Categories.length>0?CategoryWidget(cubit: cubit,selectFilters:selectFilters,Categories: Categories,isCategoriesLoading:isCategoriesLoading):height(0),
                        height(5),
                        if(cubit.stores.where((element) => element['delivery_price']==0).toList().length>0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              title(text:DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),size: 16,color:Colors.black),
                            ],
                          ),
                        cubit.stores.where((element) => element['delivery_price']==0).toList().length>0?height(15):height(0),
                        cubit.stores.where((element) => element['delivery_price']==0).toList().length>0? Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: Store(cubit: cubit,status:"freedelivery"),
                        ):height(0),
                        cubit.topChoise.length>0?Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            title(text:DemoLocalization.of(context).getTranslatedValue('Best_seller'),size: 16,color:Colors.black),
                          ],
                        ):height(0),
                        if(cubit.topChoise.length>0)
                        height(15),
                         cubit.isRestaurantsLoading?
                       Column(
                          children: [
                            if(cubit.topChoise.length>0)
                            Container(
                              width: double.infinity,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15,left: 15),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        var totalPrice = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => StorePage(
                                                  paymentMethods : cubit.topChoise[cubit.randomIndex]['payment_methods'],
                                                  name: cubit.topChoise[cubit.randomIndex]['name'],
                                                  cover: cubit.topChoise[cubit.randomIndex]['cover'],
                                                  price_delivery:cubit.topChoise[cubit.randomIndex]['delivery_price'],
                                                  oldprice_delivery:cubit.topChoise[cubit.randomIndex]['delivery_price_old'] ,
                                                  rate: cubit.topChoise[cubit.randomIndex]['rate'],
                                                  deliveryTime:cubit.topChoise[cubit.randomIndex]['delivery_time'],
                                                  cuisines: cubit.Categories,
                                                  id:cubit.topChoise[cubit.randomIndex]['id'],
                                                  slug:cubit.topChoise[cubit.randomIndex]['slug'],
                                                  brandlogo:cubit.topChoise[cubit.randomIndex]['logo'],
                                                  tags: cubit.topChoise[cubit.randomIndex]['tags'],
                                                  service_fee:cubit.topChoise[cubit.randomIndex]['service_fee']
                                                )));
                                        setState(() {
                                          totalPrice = price;
                                        });
                                      },
                                      child: Container(
                                        color:Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 0),
                                          child: Row(
                                            children: [
                                              Container(
                                                height:75,
                                                width:75,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(8)
                                                ),
                                                child:
                                                CachedNetworkImage(
                                                    width: double.infinity,
                                                    imageUrl: '${cubit.topChoise[cubit.randomIndex]['logo']}',
                                                    placeholder: (context, url) =>
                                                        Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                    imageBuilder: (context, imageProvider){
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(8),
                                                          image: DecorationImage(
                                                            image: imageProvider,
                                                            fit: BoxFit.cover,

                                                          ),
                                                        ),
                                                      );
                                                    }
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text('${cubit.topChoise[cubit.randomIndex]['name']}',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                                                    height(5),
                                                    Wrap(
                                                      crossAxisAlignment: WrapCrossAlignment.start,
                                                      children: [
                                                        Text('${cubit.Categories.map((item) => item['name']).join(' , ')}',style: TextStyle(
                                                          fontSize: 11.2,
                                                          color: Colors.grey[600],
                                                          fontWeight: FontWeight.w300,
                                                        ),),
                                                      ],
                                                    ),
                                                    height(5),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList().length>0?Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Icon(Icons.delivery_dining_outlined,color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                                                                width(5),
                                                                Text(
                                                                    cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                                    style: TextStyle(
                                                                        fontSize:11.5,
                                                                        color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
                                                                        fontWeight: FontWeight.w400)
                                                                ),
                                                                width(8),
                                                                if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price'])
                                                                  Text('${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.topChoise[cubit.randomIndex]['id']).toList()[0]['delivery_price_old']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(
                                                                      decoration: TextDecoration.lineThrough,
                                                                      fontSize:10.2,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.grey[400]
                                                                  )),
                                                              ],
                                                            ):Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SpinKitThreeBounce(
                                                                  color: Colors.grey[400],
                                                                  size: 20.0,
                                                                ),
                                                              ],
                                                            ),
                                                            width(5),
                                                            cubit.topChoise[cubit.randomIndex]['is_open']==false?Container(
                                                                height: 20,
                                                                width: 1,
                                                                color:Colors.grey[300]
                                                            ):SizedBox(height: 0,),
                                                            cubit.topChoise[cubit.randomIndex]['is_open']==false?width(5):height(0),
                                                            cubit.topChoise[cubit.randomIndex]['is_open']?
                                                            SizedBox(height: 0,):
                                                            Text(DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(
                                                                fontSize:11.5,
                                                                color:Colors.red,
                                                                fontWeight: FontWeight.w500))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    height(10),
                                    cubit.isRestaurantsLoading?
                                    Container(
                                      height: 178,
                                      width: double.infinity,
                                      child: ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: cubit.topChoise[cubit.randomIndex]['group_products'].length,
                                          itemBuilder: (context,index){
                                            return Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child:
                                              GestureDetector(
                                                onTap:()async{
                                                  var totalPrice = await showModalBottomSheet(
                                                      shape: RoundedRectangleBorder(
                                                       borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                                      ),
                                                      isScrollControlled: true,
                                                      context: context,
                                                      builder: (context) {
                                                        paymentMethods = cubit.topChoise[cubit.randomIndex]['payment_methods'];
                                                        StoreName = cubit.topChoise[cubit.randomIndex]['name'];
                                                        StoreId = cubit.topChoise[cubit.randomIndex]['id'];
                                                        deliveryPrice = cubit.topChoise[cubit.randomIndex]['delivery_price'];
                                                        olddeliveryPrice = cubit.topChoise[cubit.randomIndex]['delivery_price_old'];
                                                        paymentMethods = cubit.topChoise[cubit.randomIndex]['payment_methods'];
                                                        storeStatus = cubit.topChoise[cubit.randomIndex]['is_open'];
                                                        service_fee = cubit.topChoise[cubit.randomIndex]['service_fee'];
                                                        cubit.qty = 1;

                                                        return buildProduct(
                                                            cubit.topChoise[cubit.randomIndex]['group_products'][index],
                                                            cubit,
                                                            StoreName,
                                                            StoreId,
                                                            deliveryPrice,
                                                            storeStatus,
                                                            calculatePrice:cubit.topChoise[cubit.randomIndex]['group_products'][index]['offers']!=null?calculatePrice(double.tryParse(cubit.topChoise[cubit.randomIndex]['group_products'][index]['price']), int.tryParse(cubit.topChoise[cubit.randomIndex]['group_products'][index]['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]['config']['percentage'])):null,
                                                            offers:cubit.topChoise[cubit.randomIndex]['group_products'][index]['offers']!=null?cubit.topChoise[cubit.randomIndex]['group_products'][index]['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null
                                                        );
                                                      });

                                                },
                                                child: Container(
                                                  width: 140,
                                                  color: Colors.white,
                                                  child:  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            height: 100,
                                                            width: 130,
                                                            decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: CachedNetworkImage(
                                                                imageUrl: '${cubit.topChoise[cubit.randomIndex]['group_products'][index]['image']}',
                                                                placeholder: (context, url) =>
                                                                    ClipRRect(
                                                                        borderRadius: BorderRadius.circular(6),
                                                                        child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,width: 90,height: 90,)),
                                                                errorWidget: (context, url, error) => ClipRRect(
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,width: 90,height: 90,)),
                                                                imageBuilder: (context, imageProvider){
                                                                  return Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(6),
                                                                      image: DecorationImage(
                                                                        image: imageProvider,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      height(9),
                                                      Text(
                                                        '${cubit.topChoise[cubit.randomIndex]['group_products'][index]['name']}',
                                                        maxLines: 1,
                                                        style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                                                        overflow:TextOverflow.ellipsis,
                                                      ),
                                                      height(5),
                                                      Text.rich(TextSpan(children: [
                                                        TextSpan(
                                                          text: '${cubit.topChoise[cubit.randomIndex]['group_products'][index]['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            color: Color.fromARGB(255, 78, 78, 78),
                                                            fontSize: 12.4,
                                                          ),
                                                        ),
                                                      ])),
                                                      height(9),
                                                    ],
                                                  ),

                                                ),
                                              ),
                                            );
                                          }),
                                    ):height(0)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ):
                        
                      Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15,left:15),
                            child: Column(
                              children: [
                                Container(
                                  color:Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Row(
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300],
                                          period: Duration(seconds: 2),
                                          highlightColor: Colors.grey[100],
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            height: 75,
                                            width: 75,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  height: 10,
                                                  width: 100,
                                                ),
                                              ),
                                              height(5),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  height: 10,
                                                  width: 90,
                                                ),
                                              ),
                                              height(5),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  height: 10,
                                                  width: 55,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                height(10),
                                Container(
                                  height: 178,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: 3,
                                      itemBuilder: (context,index){
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 140,
                                            color: Colors.white,
                                            child:  Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Shimmer.fromColors(
                                                      baseColor: Colors.grey[300],
                                                      period: Duration(seconds: 2),
                                                      highlightColor: Colors.grey[100],
                                                      child: Container(
                                                        height: 100,
                                                        width: 130,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(6),
                                                          color:Colors.grey
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                height(9),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  height: 10,
                                                  width: 100,
                                                ),
                                              ),
                                                height(5),
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey[300],
                                                  period: Duration(seconds: 2),
                                                  highlightColor: Colors.grey[100],
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    height: 10,
                                                    width: 55,
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            title(text:DemoLocalization.of(context).getTranslatedValue('near_byme'),size: 16,color:Colors.black),
                          ],
                        ),
                        height(15),
                        BuildCondition(
                          condition:cubit.isNearStoresLoading,
                          builder: (context){
                            return Padding(
                              padding: const EdgeInsets.only(left: 15, right: 5),
                              child: cubit.storesNear.length>0?Container(
                                height: 190,
                                color: Colors.white,
                                child:ListView.builder(
                                    scrollDirection:Axis.horizontal,
                                    itemCount:cubit.storesNear.length,
                                    shrinkWrap:true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index){
                                      var categories = cubit.storesNear[index]['categories'].length >= 3 ? cubit.storesNear[index]['categories'].sublist(0, 3) : cubit.storesNear[index]['categories'];
                                      var offers = cubit.storesNear[index]['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder'&& e['type'] != 'freeDelivery').toList();
                                      return Padding(
                                        padding:EdgeInsets.only(left: 0,right: 10,bottom: 0),
                                        child: InkWell(
                                          onTap: ()async{
                                            var totalPrice = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) =>StorePage(
                                                      paymentMethods:cubit.storesNear[index]['payment_methods'],
                                                      name:cubit.storesNear[index]['name'],
                                                      cover:cubit.storesNear[index]['cover'],
                                                      price_delivery:cubit.storesNear[index]['delivery_price'],
                                                      oldprice_delivery:cubit.storesNear[index]['delivery_price_old'],
                                                      rate:cubit.storesNear[index]['rate'],
                                                      deliveryTime:cubit.storesNear[index]['delivery_time'],
                                                      cuisines: categories,
                                                      id:cubit.storesNear[index]['id'],
                                                      slug:cubit.storesNear[index]['slug'],
                                                      brandlogo:cubit.storesNear[index]['logo'],
                                                      tags:cubit.storesNear[index]['tags'],
                                                      service_fee:cubit.storesNear[index]['service_fee']
                                                    )
                                                )
                                            );
                                            setState(() {
                                              totalPrice = price;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            width: 280,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Stack(alignment:lg!='ar'?Alignment.topLeft:Alignment.topRight,
                                                    children:[
                                                  Container(
                                                    height: 125,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child:ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child:
                                                      Container(
                                                        color:cubit.storesNear[index]['is_open']==false?Colors.grey[200]:Color(0xffeef2f5),
                                                        child: Opacity(
                                                          opacity:cubit.storesNear[index]['is_open']==false?0.5:1,
                                                          child: CachedNetworkImage(
                                                              height: 250,
                                                              width: double.infinity,
                                                              imageUrl: '${cubit.storesNear[index]['cover']}',
                                                              placeholder: (context, url) =>
                                                                  Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                                              imageBuilder: (context, imageProvider){
                                                                return Container(
                                                                  decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  cubit.storesNear[index]['is_open']==false?
                                                  Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 52),
                                                      child: Container(
                                                          width: 78,
                                                          height: 30,
                                                          decoration:BoxDecoration(
                                                              color:Color(0xFF383737),
                                                              borderRadius: BorderRadius.circular(17)
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 11.5)),
                                                              width(3),
                                                              Icon(Icons.lock,color: Colors.white,size: 14),
                                                            ],
                                                          )),
                                                    ),
                                                  ):height(0),
                                                  if(cubit.storesNear[index]['delivery_time']!=null)
                                                    Align(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 110,left: 10,right: 10),
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors.grey[200],
                                                                    spreadRadius: 1,
                                                                    blurRadius: 2,
                                                                    offset: Offset(1, 2)
                                                                )
                                                              ],
                                                              borderRadius: BorderRadius.circular(30),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(6.0),
                                                              child: Text(' ${cubit.storesNear[index]['delivery_time']} ${DemoLocalization.of(context).getTranslatedValue('Second')} ',style: TextStyle(fontSize: 12.4,color: Colors.black,fontWeight: FontWeight.bold,),textAlign:TextAlign.center),
                                                            )),
                                                      ),
                                                      alignment:lg!='ar'?Alignment.topRight:Alignment.topLeft,
                                                    ),

                                                  if(cubit.storesNear[index]['tags'].length>0)
                                                    offers.length>0?height(0):Padding(
                                                      padding: const EdgeInsets.only(top: 10,right: 10),
                                                      child: Align(
                                                        alignment: Alignment.topLeft,
                                                        child:
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: Color(0xfffafafa),
                                                          ),

                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                                            child: Text(DemoLocalization.of(context).getTranslatedValue('nouveau'),
                                                              style:TextStyle(
                                                                  color:Color(0xffff7144),
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold
                                                              ),),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if(offers.length>0)
                                                    ...offers.map((e){
                                                      return Align(
                                                        alignment:Alignment.topRight,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 15,right: 15,left: 15),
                                                          child: Column(
                                                            children:[
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Color(0xfffafafa),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Image.asset('assets/discount.png',height: 20),
                                                                      width(2),
                                                                      Text('${e['name']}',
                                                                          style:TextStyle(
                                                                            color:Color(0xffff7144),
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),),
                                                                    ],
                                                                  ),
                                                                ),

                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                ]),
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 40,width: 40,decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    ),
                                                    child:ClipRRect(
                                                        borderRadius: BorderRadius.circular(50),
                                                        child:Image.network('${cubit.storesNear[index]['logo']}',fit:BoxFit.cover)),
                                                    ),
                                                    Padding(
                                                      padding:EdgeInsets.only(left:5,right: 5,top:cubit.storesNear[index]['delivery_time']==null?9:0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${cubit.storesNear[index]['name']}',
                                                                style:TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Color(0xFF000000),
                                                                    fontSize: 14.5),
                                                              ),
                                                            ],
                                                          ),
                                                          height(6),
                                                          cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).toList().length>0?Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Icon(Icons.star,color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey[300],size:14),
                                                              width(5),
                                                              Text('${cubit.storesNear[index]['rate'].toStringAsFixed(1)}',style: TextStyle(
                                                                  color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                  fontSize: 12
                                                              ),),
                                                              width(5),
                                                              cubit.storesNear[index]['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                                                                  color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500
                                                              ),):Text(cubit.storesNear[index]['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                                                                  color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.w500
                                                              ),),
                                                              width(5),
                                                              Rate(cubit.storesNear[index]['reviews_count'],cubit.storesNear[index]),
                                                              cubit.storesNear[index]['reviews_count']<10?width(0):width(5),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top:5),
                                                                child: Container(
                                                                  height: 5,
                                                                  width: 5,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.grey[300],
                                                                      shape: BoxShape.circle
                                                                  ),),
                                                              ),
                                                              width(4),
                                                              Icon(Icons.delivery_dining_outlined,color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                                                              width(5),
                                                              Text(
                                                                  cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                                  style: TextStyle(
                                                                      fontSize:10,
                                                                      color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
                                                                      fontWeight: FontWeight.w400)
                                                              ),
                                                            ],
                                                          ):Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SpinKitThreeBounce(
                                                                color: Colors.grey[400],
                                                                size: 20.0,
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ):height(0),
                            );
                          },
                          fallback: (context){
                            return Padding(
                              padding:EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 5),
                              child: Container(
                                height: 220,
                                color: Colors.white,
                                child:
                                ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return width(10);
                                  },
                                  physics: BouncingScrollPhysics(),
                                  itemCount:7,
                                  shrinkWrap: true,
                                  scrollDirection:Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap:(){},
                                      child:
                                      Container(
                                        decoration:BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width: 230,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(alignment: Alignment.topLeft,
                                                children: [
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey[300],
                                                    period: Duration(seconds: 2),
                                                    highlightColor: Colors.grey[100],
                                                    child: Container(
                                                      decoration:BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      height: 125,
                                                      width: 259,

                                                    ),
                                                  ),
                                                ]),
                                            height(5),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    'Motlen Chocolate',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13.5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            height(5),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5, bottom: 0),
                                                  child:Shimmer.fromColors(
                                                    baseColor: Colors.grey[300],
                                                    period: Duration(seconds: 2),
                                                    highlightColor: Colors.grey[100],
                                                    child:Container(
                                                      decoration:BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Text(
                                                        'Sandawiches  italian Fast Food',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF0A8791),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            height(4),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 4),
                                                        child: Row(children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.yellow,
                                                            size: 16,
                                                          ),
                                                          width(5),
                                                          Text(
                                                            "",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                          width(5),
                                                          Text(
                                                            "Excellent",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ]),
                                                      ),
                                                      width(5),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            height: 10,
                                                            width: 1,
                                                            color: Colors.black,
                                                          ),
                                                          width(5),
                                                          Text(
                                                            '',
                                                            style: TextStyle(
                                                                color: Colors.brown[900],
                                                                fontWeight: FontWeight.w600),
                                                          )
                                                        ],
                                                      )

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        restaurantsWithDiscount.length>0?Padding(
                          padding: const EdgeInsets.only(left: 0,right: 0,bottom:10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              title(text:DemoLocalization.of(context).getTranslatedValue('Meilleures_offres'),size: 16,color:Colors.black),
                            ],
                          ),
                        ):height(0),

                        restaurantsWithDiscount.length>0?Padding(
                          padding: const EdgeInsets.only(left: 10,right: 5),
                          child: BuildCondition(
                            condition:cubit.isNearStoresLoading,
                            builder: (context){
                              return Padding(
                                padding: const EdgeInsets.only(left: 5, right: 0),
                                child: restaurantsWithDiscount.length>0?Container(
                                  height: 200,
                                  color: Colors.white,
                                  child:ListView.builder(
                                      scrollDirection:Axis.horizontal,
                                      itemCount:restaurantsWithDiscount.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index){
                                        var categories = restaurantsWithDiscount[index]['categories'].length >= 3 ? restaurantsWithDiscount[index]['categories'].sublist(0, 3) : restaurantsWithDiscount[index]['categories'];
                                        var offers = restaurantsWithDiscount[index]['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder'&& e['type'] != 'freeDelivery').toList();
                                        return Padding(
                                          padding:EdgeInsets.only(left: 0,right: 10,bottom: 0),
                                          child: InkWell(
                                            onTap: ()async{
                                              var totalPrice = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => StorePage(
                                                          name:restaurantsWithDiscount[index]['name'],
                                                          cover:restaurantsWithDiscount[index]['cover'],
                                                          price_delivery:restaurantsWithDiscount[index]['delivery_price'],
                                                          oldprice_delivery:restaurantsWithDiscount[index]['delivery_price_old'],
                                                          rate:restaurantsWithDiscount[index]['rate'],
                                                          deliveryTime:restaurantsWithDiscount[index]['delivery_time'],
                                                          cuisines:categories,
                                                          id:restaurantsWithDiscount[index]['id'],
                                                          slug:restaurantsWithDiscount[index]['slug'],
                                                          brandlogo:restaurantsWithDiscount[index]['logo'],
                                                          tags:restaurantsWithDiscount[index]['tags'],
                                                          service_fee:restaurantsWithDiscount[index]['service_fee'],
                                                          paymentMethods:restaurantsWithDiscount[index]['payment_methods']
                                                      )));
                                              setState(() {
                                                totalPrice = price;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              width: 280,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Stack(alignment:lg=='ar'?Alignment.topLeft:Alignment.topRight,children:[
                                                    Container(
                                                      height: 125,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child:ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child:
                                                        Container(
                                                          color:restaurantsWithDiscount[index]['is_open']==false?Colors.grey[200]:Color(0xffeef2f5),
                                                          child: Opacity(
                                                            opacity:restaurantsWithDiscount[index]['is_open']==false?0.5:1,
                                                            child: CachedNetworkImage(
                                                                height: 250,
                                                                width: double.infinity,
                                                                imageUrl: '${restaurantsWithDiscount[index]['cover']}',
                                                                placeholder: (context, url) =>
                                                                    Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                imageBuilder: (context, imageProvider){
                                                                  return Container(
                                                                    decoration: BoxDecoration(
                                                                      image: DecorationImage(
                                                                        image: imageProvider,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    restaurantsWithDiscount[index]['is_open']==false?
                                                    Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 52),
                                                        child: Container(
                                                            width: 78,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                                color: Color(0xFF383737),
                                                                borderRadius: BorderRadius.circular(17)
                                                            ),
                                                            child:Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children:[
                                                                Text(DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 11.5)),
                                                                width(3),
                                                                Icon(Icons.lock,color: Colors.white,size: 14),
                                                              ],
                                                            ),
                                                        ),
                                                      ),
                                                    ):height(0),
                                                    if(restaurantsWithDiscount[index]['delivery_time']!=null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 110,left: 10,right:10),
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors.grey[200],
                                                                    spreadRadius:1,
                                                                    blurRadius:2,
                                                                    offset:Offset(1,2)
                                                                )
                                                              ],
                                                              borderRadius: BorderRadius.circular(30),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(6.0),
                                                              child: Text('${restaurantsWithDiscount[index]['delivery_time']} ${DemoLocalization.of(context).getTranslatedValue('Second')} ',style: TextStyle(fontSize: 12.4,color: Colors.black,fontWeight: FontWeight.bold,),textAlign:TextAlign.center),
                                                            )),
                                                      ),

                                                    if(restaurantsWithDiscount[index]['tags'].length>0)
                                                      offers.length>0?height(0):Padding(
                                                        padding: const EdgeInsets.only(top: 10,right: 10,left: 10),
                                                        child: Align(
                                                          alignment: Alignment.topLeft,
                                                          child:
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              color: Color(0xfffafafa),
                                                            ),

                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                                              child: Text(DemoLocalization.of(context).getTranslatedValue('nouveau'),
                                                                style:TextStyle(
                                                                    color:Color(0xffff7144),
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.bold
                                                                ),),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if(offers.length>0)
                                                      ...offers.map((e){
                                                        return Align(
                                                          alignment:Alignment.topRight,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 15,right: 15,left: 15),
                                                            child: Column(
                                                              children:[
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    color: Color(0xfffafafa),
                                                                  ),
                                                                  child:Padding(
                                                                    padding: const EdgeInsets.only(top: 4,left: 6,right: 6,bottom: 6),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Image.asset('assets/discount.png',height: 20),
                                                                        SizedBox(width: 8.0),
                                                                        Text(
                                                                            '${e['name']}',
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style:TextStyle(
                                                                              color:Color(0xffff7144),
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold,)
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                  ]),
                                                  height(10),
                                                  Row(
                                                    children: [
                                                      Container(height: 40,width: 40,decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                        child:ClipRRect(
                                                            borderRadius: BorderRadius.circular(50),
                                                            child:Image.network('${restaurantsWithDiscount[index]['logo']}',fit:BoxFit.cover)),
                                                      ),
                                                      Padding(
                                                        padding:EdgeInsets.only(left: 12,right: 10,top:restaurantsWithDiscount[index]['delivery_time']==null?9:0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '${restaurantsWithDiscount[index]['name']}',
                                                                  style:TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Color(0xFF000000),
                                                                      fontSize: 16),
                                                                ),
                                                              ],
                                                            ),
                                                            height(5),
                                                            cubit.ispriceLoading?Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children:[
                                                                Icon(Icons.star,color:restaurantsWithDiscount[index]['rate']>=3.5?Colors.green:Colors.grey[300],size:14),
                                                                width(5),
                                                                Text('${restaurantsWithDiscount[index]['rate'].toStringAsFixed(1)}',style: TextStyle(
                                                                    color:restaurantsWithDiscount[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 12
                                                                ),),
                                                                width(5),
                                                                restaurantsWithDiscount[index]['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                                                                    color:restaurantsWithDiscount[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w500
                                                                ),):Text(restaurantsWithDiscount[index]['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                                                                    color:restaurantsWithDiscount[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500
                                                                ),),
                                                                width(5),
                                                                Rate(restaurantsWithDiscount[index]['reviews_count'],restaurantsWithDiscount[index]),
                                                                restaurantsWithDiscount[index]['reviews_count']<10?width(0):width(5),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top:5),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 5,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[300],
                                                                        shape: BoxShape.circle
                                                                    ),),
                                                                ),
                                                                width(5),
                                                                Icon(Icons.delivery_dining_outlined,color:Colors.black,size: 13),
                                                                width(5),
                                                                Text(
                                                                    cubit.PriceDeliverys.where((item)=>item['store_id']==restaurantsWithDiscount[index]['id']).first['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==restaurantsWithDiscount[index]['id']).first['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                                    style: TextStyle(
                                                                        fontSize:10,
                                                                        color:cubit.PriceDeliverys.where((item)=>item['store_id']==restaurantsWithDiscount[index]['id']).first['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
                                                                        fontWeight: FontWeight.w400)
                                                                ),
                                                              ],
                                                            ):Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SpinKitThreeBounce(
                                                                  color: Colors.grey[400],
                                                                  size: 20.0,
                                                                ),
                                                              ],
                                                            )
                                                            // height(9),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ):height(0),
                              );
                            },
                            fallback:(context){
                              return Padding(
                                padding:EdgeInsets.only(left: 0,right: 15,bottom: 0,top: 5),
                                child: Container(
                                  height: 220,
                                  color: Colors.white,
                                  child:
                                  ListView.separated(
                                    separatorBuilder: (context, index) {
                                      return width(10);
                                    },
                                    physics: BouncingScrollPhysics(),
                                    itemCount:7,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: (){
                                        },
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          width: 230,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(alignment: Alignment.topLeft,
                                                  children: [
                                                    Shimmer.fromColors(
                                                      baseColor: Colors.grey[300],
                                                      period: Duration(seconds: 2),
                                                      highlightColor: Colors.grey[100],
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        height: 125,
                                                        width: 259,

                                                      ),
                                                    ),
                                                  ]),
                                              height(5),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Shimmer.fromColors(
                                                  baseColor: Colors.grey[300],
                                                  period: Duration(seconds: 2),
                                                  highlightColor: Colors.grey[100],
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Text(
                                                      'Motlen Chocolate',
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              height(5),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5, bottom: 0),
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors.grey[300],
                                                      period: Duration(seconds: 2),
                                                      highlightColor: Colors.grey[100],
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Text(
                                                          'Sandawiches  italian Fast Food',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF0A8791),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              height(4),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Shimmer.fromColors(
                                                  baseColor: Colors.grey[300],
                                                  period: Duration(seconds: 2),
                                                  highlightColor: Colors.grey[100],
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 4),
                                                          child: Row(children: [
                                                            Icon(
                                                              Icons.star,
                                                              color: Colors.yellow,
                                                              size: 16,
                                                            ),
                                                            width(5),
                                                            Text(
                                                              "",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                            width(5),
                                                            Text(
                                                              "Excellent",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                          ]),
                                                        ),
                                                        width(5),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 10,
                                                              width: 1,
                                                              color: Colors.black,
                                                            ),
                                                            width(5),
                                                            Text(
                                                              '',
                                                              style: TextStyle(
                                                                  color: Colors.brown[900],
                                                                  fontWeight: FontWeight.w600),
                                                            )
                                                          ],
                                                        )

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ):height(0),

                        cubit.stores.length>0?Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: title(text:service_type=='food'?DemoLocalization.of(context).getTranslatedValue('Tous_les_restaurants'):DemoLocalization.of(context).getTranslatedValue('Tous_les_stores'),size: 16,color:Colors.black),
                            ),
                            height(7),
                            Padding(
                              padding: const EdgeInsets.only(right: 10,left: 10),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                        color: Color.fromARGB(255, 230, 230, 230)
                                    )
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    width(5),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          islist = true;
                                        });
                                      },
                                      child: Container(
                                          child: Icon(Icons.monitor_rounded,size: 20,color:islist==false?Color.fromARGB(255, 230, 230, 230):Colors.red,)),
                                    ),
                                    width(10),
                                    Container(
                                      height: 15,
                                      width: 0.4,
                                      color: Color.fromARGB(255, 184, 184, 184),
                                    ),
                                    width(10),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          islist = false;
                                        });
                                      },
                                      child: Icon(Icons.list_rounded,size: 23,color:islist!=false?Color.fromARGB(255, 230, 230, 230):AppColor,),
                                    ),
                                    width(5),
                                  ],
                                ),
                              ),
                            )

                          ],
                        ):height(0),
                        height(10),
                        cubit.isRestaurantsLoading?Column(
                          children: [
                            islist==false?
                           ListView.separated(
                              separatorBuilder: (context, index){
                                if(index !=cubit.stores.length ~/4) {
                                  return Divider(
                                    height: 2,
                                  );
                                }else{
                                  return height(0);
                                }
                              },
                              itemCount:cubit.stores.length + 1,
                             
                              shrinkWrap:true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final newStores = cubit.stores.where((store) => store['tags'].contains('new')).toList();
                                if (index == cubit.stores.length ~/ 3) {
                                  return cubit.stores.length==1?height(0):Column(
                                    children: [
                                      newStores.length>0?Padding(
                                        padding:EdgeInsets.only(right:islist==false?10:20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            title(text:DemoLocalization.of(context).getTranslatedValue('Nouveaux_restaurants_avec_nous'),size: 16,color:Colors.black),
                                          ],
                                        ),
                                      ):height(0),
                                      height(13),
                                      newStores.length>0? Padding(
                                        padding:EdgeInsets.only(right:islist==false?10:20),
                                        child: buildStores(cubit.isRestaurantsLoading,newStores,cubit.ispriceLoading,cubit.PriceDeliverys),
                                      ):height(0)
                                    ],
                                  );
                                } else if (index > cubit.stores.length ~/3){
                                  final item = cubit.stores[index-1];
                                  return  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 15,top: 10),
                                    child: StoreList(Restaurant:item,id:item['id'],ispriceLoading: cubit.ispriceLoading,PriceDeliverys: cubit.PriceDeliverys),
                                  );
                                } else {
                                  final item =  cubit.stores[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 15,top: 10),
                                    child: StoreList(Restaurant:item,id:item['id'],ispriceLoading: cubit.ispriceLoading,PriceDeliverys: cubit.PriceDeliverys),
                                  );
                                }
                              },
                            )
                         :ListView.builder(
                                itemCount:cubit.stores.length + 1,
                                shrinkWrap:true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final newStores =  cubit.stores.where((store) => store['tags'].contains('new')).toList();
                                  if (index == cubit.stores.length ~/ 2) {
                                    return newStores.length>0?Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 10),
                                      child: cubit.stores.length==1?height(0):Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              title(text:DemoLocalization.of(context).getTranslatedValue('Nouveaux_restaurants_avec_nous'),size: 16,color:Colors.black),
                                            ],
                                          ),
                                          height(13),
                                          buildStores(cubit.isRestaurantsLoading,newStores,cubit.ispriceLoading,cubit.PriceDeliverys),
                                        ],
                                      ),
                                    ):height(0);
                                  }
                                  else if (index > cubit.stores.length ~/ 2) {
                                    final item = cubit.stores[index-1];
                                    return  Padding(
                                      padding:EdgeInsets.only(left: 20,right: 20,bottom: 15,top: 10),
                                      child: StoreGridl(Restaurant:item,id:item['id'],ispriceLoading:cubit.ispriceLoading,PriceDeliverys: cubit.PriceDeliverys),
                                    );
                                  } else {
                                    final item = cubit.stores[index];
                                    return Padding(
                                      padding:EdgeInsets.only(left: 20,right: 20,bottom: 15),
                                      child: StoreGridl(Restaurant:item,id:item['id'],size: 220.0,ispriceLoading:cubit.ispriceLoading,PriceDeliverys: cubit.PriceDeliverys),
                                    );
                                  }

                                }
                            )
                          ],
                        ):
                        cubit.stores.length>0?ListView.builder(
                            shrinkWrap: true,
                            itemCount: 5,
                            itemBuilder: (context,index){
                              return Padding(
                                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0,bottom: 0,right: 5),
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.grey[300],
                                          period: Duration(seconds: 2),
                                          highlightColor: Colors.grey[100],
                                          child: Container(
                                            width: 75,
                                            height: 75,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.grey
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:EdgeInsets.only(left: 12,right: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey[300],
                                                    period: Duration(seconds: 2),
                                                    highlightColor: Colors.grey[100],
                                                    child: Container(
                                                      child: Text(
                                                        'Starbucks',
                                                        style:TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: Color(0xFF000000),
                                                            fontSize: 15),
                                                      ),
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              height(3),


                                              height(5),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  color: Colors.grey,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.star,color: Colors.yellow,size: 14,),
                                                      width(5),
                                                      Text(
                                                          '11 Excellent',
                                                          style: TextStyle(
                                                              fontSize:10.5,
                                                              color: Color.fromARGB(255, 68, 71, 71), fontWeight: FontWeight.w500)
                                                      ),
                                                      width(5),
                                                      Container(
                                                        height: 10,
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                      width(5),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.timer_outlined,color: Colors.black,size: 14,),
                                                          width(2.5),
                                                          Text(
                                                              '12 min',
                                                              style: TextStyle(
                                                                  fontSize:10.5,
                                                                  color: Color.fromARGB(255, 78, 78, 78), fontWeight: FontWeight.w500)
                                                          ),
                                                          width(5),
                                                          Container(
                                                            height: 10,
                                                            width: 1,
                                                            color: Colors.black,
                                                          ),
                                                          width(5),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.delivery_dining_outlined,color: Colors.black,size: 14,),
                                                              width(5),
                                                              Text(
                                                                  'Free Delivery',
                                                                  style: TextStyle(
                                                                      fontSize:10.5,
                                                                      color: Color.fromARGB(255, 78, 78, 78), fontWeight: FontWeight.w500)
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              height(3),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  color: Colors.grey,
                                                  child: Text(
                                                    '25 % off entire menu',
                                                    style:TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.red,
                                                        fontSize: 11.8),
                                                  ),
                                                ),
                                              ),
                                              // height(9),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }):height(0),
                      ],
                    )
                )
              );
            },
          );

        },
      ),
    );
  }

  // SafeArea Filter(ShopCubit cubit, BuildContext context) {
  //   return SafeArea(
  //                                       child: Scaffold(
  //                                         backgroundColor:Colors.white,
  //                                         bottomNavigationBar:
  //                                         Container(
  //                                           width: double.infinity,
  //                                           decoration: BoxDecoration(
  //                                             color: Colors.white,
  //                                             borderRadius: BorderRadius.circular(0),
  //                                           ),
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.only(left: 10, right: 15, top: 15, bottom: 15),
  //                                             child: GestureDetector(
  //                                               onTap:(){
  //                                                  print(selectFilters);
  //                                                  text = "";
  //                                                  selectFilters.forEach((element) {
  //                                                    text = text + element + ',';
  //                                                  });
  //                                                  print(text);
  //                                                  setState(() {
  //                                                    cubit.FilterData(
  //                                                        longitude:longitude,
  //                                                        latitude:latitude,
  //                                                        text:text
  //                                                    );
  //                                                  });
  //
  //                                               },
  //                                               child: Container(
  //                                                 height: 50,
  //                                                 decoration: BoxDecoration(
  //                                                     borderRadius: BorderRadius.circular(5),
  //                                                     color: Color(0xFFe9492d)),
  //                                                 width: double.infinity,
  //                                                 child: Center(
  //                                                     child: Text(
  //                                                       "فلتر",
  //                                                       style: TextStyle(
  //                                                         fontSize: 20,
  //                                                         color: Colors.white,
  //                                                         fontWeight: FontWeight.bold,
  //                                                       ),
  //                                                       textAlign: TextAlign.center,
  //                                                     )),
  //                                               ),
  //                                             ),),
  //                                         ),
  //                                         appBar: AppBar(
  //                                           backgroundColor: Colors.white,
  //                                           automaticallyImplyLeading: false,
  //                                           toolbarHeight: 70,
  //                                           title: Padding(
  //                                             padding: const EdgeInsets.only(top: 30),
  //                                             child: Text('بحث و فلتر',style: TextStyle(
  //                                                 fontWeight: FontWeight.bold,
  //                                                 color: Colors.black,
  //                                                 fontSize: 19),),
  //                                           ),
  //                                           centerTitle: true,
  //                                           elevation: 0,
  //                                           leading: Padding(
  //                                             padding: const EdgeInsets.only(top: 30),
  //                                             child: GestureDetector(
  //                                                 onTap: (){
  //                                                   Navigator.of(context).pop();
  //                                                 },
  //                                                 child: Icon(Icons.arrow_back,color: Colors.black,)),
  //                                           ),
  //                                         ),
  //                                         body:buildFilter(selectCategories:selectFilters),
  //                                       ));
  // }

  StepperData Stepper(
      {String title,
        Color color,
        Color containerColor,
        FontWeight fontWeight,
        IconData icon}) {
    return StepperData(
        iconWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.all(Radius.circular(30)
              )
          ),
          child: Icon(icon, color: Colors.white,size: 10),
        ));
  }

  status(String status) {
    if (status == 'pending') {
      return DemoLocalization.of(context).getTranslatedValue('pending');
    }
    if (status == 'confirmation on process') {
      return DemoLocalization.of(context).getTranslatedValue('confirmation_on_process');
    }
    if(status == 'on process'){
      return DemoLocalization.of(context).getTranslatedValue('on_process');
    }
    if(status == 'ready'){
      return DemoLocalization.of(context).getTranslatedValue('ready');
    }
    if(status == 'delivery process'){
      return DemoLocalization.of(context).getTranslatedValue('delivery_process');
    }
    if(status == 'delivered'){
      return DemoLocalization.of(context).getTranslatedValue('delivered');
    }
    if(status == 'non-accepted'){
      return DemoLocalization.of(context).getTranslatedValue('non_accepted');
    }else{
      return DemoLocalization.of(context).getTranslatedValue('non_accepted');
    }

  }


  Widget buildProduct(product,cubit,StoreName,StoreId,deliveryPrice,storeStatus,{double calculatePrice,offers}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            product['image']!=''? Container(
              height: 300,
              width: double.infinity,
              child:product['image']==''?
              Image.asset('assets/placeholder.png',):
              CachedNetworkImage(
                  imageUrl: '${product['image']}',
                  placeholder: (context, url) =>
                      Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageBuilder: (context, imageProvider){
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover
                        ),
                      ),
                    );
                  }
              ),


            ):height(0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  setState((){
                    Navigator.pop(
                        context, '${cubit.getTotalPrice()}');
                  });
                },
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close,color: Colors.black,size: 25)),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15,top: 20,right: 15),
          child: Text('${product['name']}',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
        ),
        product['description']!=null?   Padding(
          padding: const EdgeInsets.only(left: 15,top: 20,right: 15),
          child: Column(

            children: [
              Text(
                '${product['description']}',
                style:
                TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ):height(0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            calculatePrice!=null? Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color:Colors.grey[400],decoration: TextDecoration.lineThrough),),
            ):height(0),
            Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${calculatePrice==null?product['price']:calculatePrice} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
            ),

          ],
        ),

        height(20),
        StatefulBuilder(builder: (context,setState){
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            height: 75,
            child: Padding(
              padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 10),
              child: GestureDetector(
                onTap: (){
                  StoreId = StoreId;
                  deliveryPrice = deliveryPrice;
                  cubit.addToCart(
                      product:product,
                      Qty:cubit.qty,
                      productStoreId:StoreId,
                      attributes:[],
                      storeStats: storeStatus,
                      offers:offers,
                      storeName:StoreName

                  );
                  if(cubit.isinCart){
                    Navigator.pop(context, '${cubit.getTotalPrice()}');
                  }
                  if(cubit.isinCart==false){
                    print('${cubit.isinCart}');
                    dataService.itemsCart.clear();
                    dataService.productsCart.clear();
                    cubit.addToCart(
                        product:product,
                        Qty:cubit.qty,
                        productStoreId:StoreId,
                        attributes:[],
                        storeStats: storeStatus,
                        offers:offers
                    );
                    if(cubit.isinCart){
                      Navigator.pop(context, '${cubit.getTotalPrice()}');
                    }
                  }


                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height:50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:AppColor,
                        ),
                        width: double.infinity,
                        child: Center(child: Text(DemoLocalization.of(context).getTranslatedValue('Ajouter_au_panier'),style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
                        )
                        ),
                      ),
                    ),
                    width(5),
                    StatefulBuilder(builder: (context,setState){
                      return Expanded(
                        child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color:Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Icon(Icons.remove,color: Colors.black,size: 30,),
                                ),
                                onTap: (){
                                  cubit.minus();
                                  setState((){});
                                },
                              ),
                              width(20),
                              Text('${cubit.qty}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),),
                              width(20),
                              GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Icon(Icons.add,color: Colors.black,size: 30,),
                                ),
                                onTap: (){
                                  cubit.plus();
                                  setState((){});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          );
        }),

      ],
    );
  }

  Widget rate(rate_count,Restaurant){
    if (rate_count > 20) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
            color: Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('20',style: TextStyle(
            color: Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
        ],
      );
    } else if(rate_count > 10){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
            color: Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('10',style: TextStyle(
            color: Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
        ],
      );
    } else {
      return Text(rate_count<10?"":'${rate_count}');
    }
  }
}




