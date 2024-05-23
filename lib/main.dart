import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopapp/Layout/HomeLayout/account.dart';
import 'package:shopapp/referrel_link.dart';
import 'package:shopapp/shared/bloc_observer.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:shopapp/shared/network/remote/cachehelper.dart';
import 'Layout/HomeLayout/layoutScreen.dart';
import 'Utils/dynamic_link.dart';
import 'localization/demo_localization.dart';
import 'localization/localization_constants.dart';
import 'modules/pages/Order/operationOrder.dart';
import 'Utils/splash_screen.dart';
import 'modules/pages/Static/support_service.dart';
import 'Utils/update.dart';
import 'shared/network/remote/dio_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:connectivity/connectivity.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<bool>checkupdate() async {
  final info = await PackageInfo.fromPlatform();
  String appVersion = info.buildNumber;

  RemoteConfig remoteConfig = RemoteConfig.instance;
  remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 60),
      minimumFetchInterval: Duration(seconds: 1)
  ));
  await remoteConfig.fetchAndActivate();
  String remoteConfigVersion = remoteConfig.getString('appVersion');

  if (remoteConfigVersion.compareTo(appVersion)==1)
    return true;
  else
    return false;
}

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder=(FlutterErrorDetails details)=>Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,size: 60,color: AppColor),
            height(5),
            Text('! معذرة ',style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500
            ),),
            height(20),
            Text('حدث خطأ ما. أعد المحاولة من فضلك'),

          ],
        ),
      )
  );
  DioHelper.init();
  Cachehelper.init();
  await Firebase.initializeApp();
  DynamicLinkProvider().initDynamicLink();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale local) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(local);
  }
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      print(_locale);
    });
  }
  @override
  void didChangeDependencies() {
    getLocale().then((locale){
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }
  @override
  void initState() {
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Canari',
        theme: ThemeData(
          fontFamily: 'Almarai',
          appBarTheme:AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.white,
              )),

        ),
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('fr','US'),Locale('ar', 'EG')
        ],
        locale:_locale,
        localizationsDelegates:[
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback:(deviceLocal,supportedLocales){
          if(deviceLocal!=null){
            for (var local in supportedLocales) {
              if (local.languageCode == deviceLocal.languageCode){
                lg = deviceLocal.languageCode;
                return deviceLocal;
              }
            }
          }
          return supportedLocales.first;

        },
        home:StreamBuilder<ConnectivityResult>(
          stream: Connectivity().onConnectivityChanged,
          builder:(context,snapshot){
            return snapshot.data == ConnectivityResult.none ? Scaffold(
              body: Center(
               child: Text('no network connecting'),
              ),
            ):InializeWidget();
          },
        )
    );
  }



}

class InializeWidget extends StatefulWidget {
  const InializeWidget({Key key}) : super(key: key);
  @override
  State<InializeWidget> createState() => _InializeWidgetState();
}

class _InializeWidgetState extends State<InializeWidget> {

  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:FutureBuilder(
          future:checkupdate(),
          builder: (BuildContext context,snapshot){
            return snapshot.data==true?Update():SplashScreen();
          },
        )
    );
  }
}
