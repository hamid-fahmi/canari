import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopapp/Layout/HomeLayout/layoutScreen.dart';
import 'package:shopapp/modules/pages/Order/checkout_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shopapp/shared/network/remote/cachehelper.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/constants.dart';

import 'home.dart';

class SelectAddres extends StatefulWidget {
  final String routing;
 final rout;
  final store;
  final paymentMethods;
  final service_fee;
  final olddelivery_price;
  final delivery_price;
  const SelectAddres({Key key, this.routing, this.rout, this.store, this.paymentMethods, this.service_fee, this.olddelivery_price, this.delivery_price}) : super(key: key);

  @override
  _SelectAddresState createState() => _SelectAddresState();
}

class _SelectAddresState extends State<SelectAddres> {
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");

  bool isCameraMove = false;
  var myLocation = 'اختر موقع';
  Completer<GoogleMapController> _controller = Completer();
  double lat = Cachehelper.getData(key: "latitude");
  Position currentPosition;
  // var latitude;
  // var longitude;
  bool locationCollected = true;
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


  // Future<Position> getLocation() async {
  //   if(lat==null) {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.low).then((value) {
  //       Cachehelper.sharedPreferences.setDouble('latitude',
  //           value.latitude);
  //       Cachehelper.sharedPreferences.setDouble('longitude',
  //           value.longitude);
  //       latitud = value.latitude;
  //       longitud = value.longitude;
  //       setState(() {
  //
  //       });
  //       return value;
  //     });
  //     _animateCamera(position);
  //     return position;
  //   }
  //
  // }

  // Future<void> _getCurrentPosition() async{
  //   final hasPermission = await handleLocationPermission();
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //        latitude = position.latitude;
  //        longitude = position.longitude;
  //        locationCollected = true;
  //        myMarkers.add(Marker(markerId: MarkerId('1'),position: LatLng(latitud==null?27.149890:latitud,longitud==null?-13.199970:longitud)));
  //        _animateCamera(position);
  //     setState(() => currentPosition = position);
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

  Future<void> _animateCamera(Position position)async{
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
        target:LatLng(position.latitude, position.longitude),
      zoom: 15.4746
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
   }

  Future getPlace({latitude,longitude,bool myaddres})async{
    print(myaddres);
    List placemarks = await placemarkFromCoordinates(latitude,longitude);
    if (mounted) {
      setState(() {
        myLocation = placemarks[0].street;
        print(latitude);
        print(longitude);
      });
    }


  }

  Set<Marker>myMarkers={

  };





  @override
  void initState(){
    handleLocationPermission().then((value){
      Geolocator.getCurrentPosition().then((value)async{
        myMarkers.add(Marker(markerId: MarkerId('1'),position: LatLng(latitud==null?27.149890:value.latitude,longitud==null?-13.199970:value.longitude)));
        _animateCamera(value);
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
          Cachehelper.sharedPreferences.setDouble('latitude',value.latitude);
          Cachehelper.sharedPreferences.setDouble('longitude',value.longitude);
        });

        List placemarks = await placemarkFromCoordinates(latitude,longitude);
        if (mounted) {
          setState(() {
            myLocation = placemarks[0].street;
            print(latitude);
            print(longitude);
          });
        }

      });
    });
    myMarkers.add(Marker(markerId: MarkerId('1'),position: LatLng(latitud==null?27.149890:latitud,longitud==null?-13.199970:longitud)));    getPlace(latitude:latitud==null?27.149890:latitud,longitude:longitud==null?-13.199970:longitud);
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    bool isCameraMoved = Cachehelper.getData(key: "isCameraMove");
    return Directionality(
      textDirection: TextDirection.ltr,
      child: WillPopScope(
        onWillPop: ()async{
          if(widget.routing=="homepage"){
            myLocation = myLocation;
            Cachehelper.sharedPreferences.setString('myLocation', myLocation);
            Cachehelper.sharedPreferences.setDouble('latitude', latitude);
            Cachehelper.sharedPreferences.setDouble('longitude', longitude);
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Home(
              myLocation:myLocation,
              latitude:latitude,
              longitude:longitude,
            )));
          }
          return true;
        },
        child: Scaffold(
          bottomNavigationBar:
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:Colors.grey[400],
                    blurRadius:8,
                    spreadRadius:3,
                    offset:Offset(0,2)
                  )
                ],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                  topLeft: Radius.circular(20),
                )
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child:Text(DemoLocalization.of(context).getTranslatedValue('select_loaction'),style: TextStyle(
                      fontSize:20,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:20,left:20,top: 20),
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child:myLocation!=null?Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on,color: AppColor,),
                            Expanded(
                              child: Text('${myLocation}',
                              style: TextStyle(
                               fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis
                              ),
                                maxLines:myLocation.length>=30?2:1,
                              ),
                            ),
                          ],
                        ),
                      ):Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(DemoLocalization.of(context).getTranslatedValue('loaction'),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:20,left:20,top: 10),
                    child: GestureDetector(
                      onTap: (){
                        if(latitude!=null && longitude!=null){
                          if(widget.routing== "homelayout"){
                            myLocation = myLocation;
                            Cachehelper.sharedPreferences.setString('myLocation',
                                myLocation);
                            Cachehelper.sharedPreferences.setDouble('latitude',
                                latitude);
                            Cachehelper.sharedPreferences.setDouble('longitude',
                                longitude);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) =>
                                    Home(
                                      myLocation: myLocation,
                                      latitude: latitude,
                                      longitude: longitude,
                                      category: 'food',
                                    )));
                            setState(() {

                            });
                          }
                        if (widget.routing == "homepage") {
                          myLocation = myLocation;
                          Cachehelper.sharedPreferences.setString('myLocation',
                              myLocation);
                          Cachehelper.sharedPreferences.setDouble('latitude',
                              latitude);
                          Cachehelper.sharedPreferences.setDouble('longitude',
                              longitude);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>
                                  Home(
                                    myLocation: myLocation,
                                    latitude: latitude,
                                    longitude: longitude,
                                  )));
                          setState(() {

                          });
                        }
                        if (widget.routing == "restaurantPage") {
                          myLocation = myLocation;
                          Cachehelper.sharedPreferences.setString('myLocation',
                              myLocation);
                          Cachehelper.sharedPreferences.setDouble('latitude',
                              latitude);
                          Cachehelper.sharedPreferences.setDouble('longitude',
                              longitude);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    rout: widget.rout,
                                    olddelivery_price: widget.olddelivery_price,
                                    service_fee: widget.service_fee,
                                    delivery_price: widget.delivery_price,
                                    paymentMethods:widget.paymentMethods,
                                    store: widget.store,
                                  )),(
                              route) => true);
                                setState(() {

                                });
                               }
                        if (widget.routing == "checkout") {
                myLocation = myLocation;
                Cachehelper.sharedPreferences.setString('myLocation',
                    myLocation);
                Cachehelper.sharedPreferences.setDouble(
                    'latitude', latitude);
                Cachehelper.sharedPreferences.setDouble(
                    'longitude', longitude);
                setState(() {
                  Navigator.pop(context, '${myLocation}');
                });
              }
                         }else{
                          print('moveCamera');
                        }
                      },
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:latitude==null && longitud==null?Colors.grey:Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:Center(
                          child:Text(latitude==null && longitud==null?lg=='ar'?'جاري تحديد موقعك...':"Localisation de votre emplacement":DemoLocalization.of(context).getTranslatedValue('confirm_location'),style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // child: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text('تسليم الى',style: TextStyle(color: Color.fromARGB(255, 116, 117, 117),fontWeight: FontWeight.w400,fontSize: 14.50)),
              //     height(8),
              //     Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         Icon(Icons.location_on_outlined,size: 17,color: Colors.red),
              //         width(6),
              //         Expanded(child: Text('${myLocation}',style: TextStyle(color: Color.fromARGB(255, 68, 71, 71),fontWeight: FontWeight.w600,fontSize: 14,),maxLines: 1,)),
              //       ],
              //     ),
              //     height(8),
              //     GestureDetector(
              //       onTap:(){
              //         if(isCameraMoved!=null&&isCameraMoved==true){
              //           if (widget.routing == "homepage") {
              //             myLocation = myLocation;
              //             Cachehelper.sharedPreferences.setString('myLocation',
              //                 myLocation);
              //             Cachehelper.sharedPreferences.setDouble('latitude',
              //                 latitude);
              //             Cachehelper.sharedPreferences.setDouble('longitude',
              //                 longitude);
              //             Navigator.pushReplacement(context,
              //                 MaterialPageRoute(builder: (context) =>
              //                     MyHomePage(
              //                       myLocation: myLocation,
              //                       latitude: latitude,
              //                       longitude: longitude,
              //                       timestart: TimeStart,
              //                       timeend: TimeEnd,
              //                     )));
              //             setState(() {
              //
              //             });
              //           }
              //           if (widget.routing == "restaurantPage") {
              //             myLocation = myLocation;
              //             Cachehelper.sharedPreferences.setString('myLocation',
              //                 myLocation);
              //             Cachehelper.sharedPreferences.setDouble('latitude',
              //                 latitude);
              //             Cachehelper.sharedPreferences.setDouble('longitude',
              //                 longitude);
              //             Navigator.of(context).pushAndRemoveUntil(
              //                 MaterialPageRoute(
              //                     builder: (context) => CheckoutPage()), (
              //                 route) => true);
              //             setState(() {
              //
              //             });
              //           }
              //           if (widget.routing == "checkout") {
              //             myLocation = myLocation;
              //             Cachehelper.sharedPreferences.setString('myLocation',
              //                 myLocation);
              //             Cachehelper.sharedPreferences.setDouble(
              //                 'latitude', latitude);
              //             Cachehelper.sharedPreferences.setDouble(
              //                 'longitude', longitude);
              //             setState(() {
              //               Navigator.pop(context, '${myLocation}');
              //             });
              //           }
              //         }else{
              //           print('moveCamera');
              //         }
              //       },
              //
              //       child: Container(
              //           decoration: BoxDecoration(
              //               color:isCameraMoved!=null&&isCameraMoved==true?AppColor:Colors.grey[400],
              //               borderRadius: BorderRadius.circular(5)
              //           ),
              //           height: 50,
              //           width: double.infinity,
              //           child: Center(child: Text(isCameraMoved!=null&&isCameraMoved==true?'تسليم هنا':'اختر موقع تسليم',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),))),
              //     ),
              //     height(10),
              //   ],
              // ),
            ),
          ),
                 floatingActionButton:Padding(
                    padding:const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: 30,
                          child:IconButton(
                            icon:locationCollected?Icon(Icons.location_searching):CircularProgressIndicator(backgroundColor:Colors.white),
                            onPressed: ()async{
                              setState(() {
                                locationCollected = false;
                              });
                              handleLocationPermission().then((value){
                                Geolocator.getCurrentPosition().then((value) {
                                  myMarkers.add(Marker(markerId: MarkerId('1'),position: LatLng(latitud==null?27.149890:value.latitude,longitud==null?-13.199970:value.longitude)));
                                  _animateCamera(value);
                                  print('${value.latitude}');
                                  setState(() {
                                    locationCollected = true;
                                  });
                                  print('${value.longitude}');
                                });
                              });
                              // setState(() {
                              //   locationCollected = false;
                              // });
                              // _handleLocationPermission().then((value) {
                              //   locationCollected = true;
                              // });
                              // _getCurrentPosition().then((value){
                              //   locationCollected = true;
                              // });
                            },),
                        )

                      ],
                    ),
                  ),
                  body:
                  GoogleMap(
                    zoomControlsEnabled:true,
                    zoomGesturesEnabled:true,

                    mapType:MapType.normal,
                    onMapCreated: (GoogleMapController controller){
                      _controller.complete(controller);
                    },
                    onCameraMove: (CameraPosition position){
                      setState((){});
                      myMarkers.remove(Marker(markerId: MarkerId('1')));
                      myMarkers.add(Marker(markerId: MarkerId('1'),position: LatLng(position.target.latitude, position.target.longitude)));
                      latitude =position.target.latitude;
                      longitude= position.target.longitude;
                      setState((){
                      });
                    },
                    onCameraIdle: (){
                      setState(() {
                        getPlace(longitude:longitude ,latitude: latitude);
                      });
                    },

                    initialCameraPosition:CameraPosition(
                      target: LatLng(latitud==null?27.149890:latitud,longitud==null?-13.199970:longitud),
                      zoom: 15.2356,
                    ),
                    markers: myMarkers,
                  ),
                ),
      ),
    );
  }


}



