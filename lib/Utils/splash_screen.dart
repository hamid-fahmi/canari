import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shopapp/Layout/HomeLayout/layoutScreen.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'dart:io';
import '../Layout/HomeLayout/home.dart';
import '../Layout/HomeLayout/selectAddres.dart';
import '../Layout/shopcubit/storecubit.dart';
import '../Layout/shopcubit/storestate.dart';
import '../class/langauge.dart';
import '../localization/localization_constants.dart';
import '../main.dart';
import '../shared/components/components.dart';
import '../shared/network/remote/cachehelper.dart';
import '../shared/network/remote/dio_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  AnimationController controller;
  bool isloading = true;

  String selectelang = '';
  String language = Cachehelper.getData(key:"langugeCode");
  void _changeLanguge(Language lang) async{
    Locale _temp = await setLocale(lang.languageCode);
    MyApp.setLocale(context, _temp);
    setState(() {
      lg = lang.languageCode;
      Cachehelper.sharedPreferences.setString("langugeCode",lang.languageCode);
      print('lang is :${lg}');
      if(lg=='fr'){
        selectelang = 'Français';
      }else{
        selectelang = 'العربية';
      }
    });
  }
 Future<void> getConfig()async{
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  await DioHelper.getData(
      url: 'https://api.canariapp.com/v1/client/config',
    ).then((value) {

      value.data.forEach((e){
        if(e['key']=='payment_by_card'){
          setState(() {
            dataService.payment_by_card = e['value'];
          });
        }

        if(e['key']=='weather_fee'){
          setState(() {
             dataService.weather_fee =e['value'];

          });
        }

        if(e['key']=='service_fee_calculation'){
          setState(() {
            dataService.value = e['value'];

          });
        }

        if(e['key']=='share_app'){
          setState(() {
            share_app = e['value'];

          });
        }

        if(e['key']=='coupon_page'){
          setState(() {
            coupon_page = e['value'];

          });
        }

        if(e['key']=='start_with_location'){
          setState(() {
            start_with_location = e['value'];

          });
        }

        if(e['key']=='location_alert'){
          setState(() {
            location_alert = e['value'];

          });
        }

        if(e['key']=='grocery_market_id'){
          setState(() {
            grocery_market_id = e['value'];
          });
        }

        setState((){

        });
      });
    }).catchError((error) {
      print(error.toString());
      setState(() {
        isloading = true;
        if(isSelectlang!=null){
          if(latitud==null){
            if(start_with_location){
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context)=>SelectAddres(
                    routing: "homelayout",
                  )),(route) => false);
            }else{
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context)=> LayoutScreen()), (route) => false);
            }
          }else{
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context)=>LayoutScreen()), (route) => false);
          }
        }
      });
    });
  }

  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  String MyLocation = Cachehelper.getData(key: "myLocation");
  bool isSelectlang = Cachehelper.getData(key: "isLangSelect");


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      selectelang = 'Français';
      getConfig().then((value){
        // Future.delayed(Duration(seconds:1),(){
        //   isloading = true;

        //
        // });
      });
    });
    controller = AnimationController(vsync: this,duration: Duration(seconds:3));
    controller.addStatusListener((status)async {
      if (status==AnimationStatus.completed){

          if(latitud==null){
            if(start_with_location){
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context)=>SelectAddres(
                    routing: "homelayout",
                  )),(route) => false);
            }else{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home(latitude:latitud,longitude:longitud,myLocation:MyLocation,category:'food',)));
            }
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home(latitude:latitud,longitude:longitud,myLocation:MyLocation,category:'food',)));
          }




        controller.reset();


      }
    });
  }
  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor:Colors.transparent)
    );
    return
      BlocProvider(
        create: (BuildContext context) => StoreCubit(),
        child: BlocConsumer<StoreCubit, ShopStates>(
          listener: (context,state){},
          builder: (context,state){
            return Scaffold(
                body: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: AppColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/nnn.json',
                              height: 200,
                              repeat: false,
                              controller: controller,
                              onLoaded:(LottieComposition){
                                controller.forward();
                                setState(() {

                                });
                              }),
                          //    height(50),
                          // CircularProgressIndicator(
                          //   color: Colors.white,
                          // ),
                        ],
                      ),
                    )
                  ],
                )
            );
          },
        ),
      );
  }
}
