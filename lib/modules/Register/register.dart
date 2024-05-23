import 'dart:convert';
import 'dart:io';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/localization/demo_localization.dart';

import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../otp/getOtp.dart';
import '../../shared/network/remote/cachehelper.dart';
import '../pages/Order/operationOrder.dart';
import '../pages/Order/order.dart';
import '../pages/Order/paymentPage.dart';

enum MobileVerificationState { SHOW_MOBILE_FROM_STATE, SHOW_OTP_FROM_STATE }
class Register extends StatefulWidget {
  final String routing;
  final TextEditingController NoteController;
  final TextEditingController CouponController;
  final TextEditingController emailController;
  final total;
  final paymentMethod;
  final service_fee;
  final wether_fee;
  final coupon;
  const Register({Key key, this.routing,this.NoteController,this.total,this.CouponController,this.paymentMethod, this.service_fee, this.wether_fee, this.emailController, this.coupon}) : super(key: key);
  @override
  State<Register> createState() => _RegisterState();
}
class _RegisterState extends State<Register> {
  var fbm = FirebaseMessaging.instance;
  final _key = UniqueKey();
  String urlwebview;
  String fcmtoken='';
  bool isloading = true;
  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FROM_STATE;
  final GlobalKey<FormState> otpkey = GlobalKey<FormState>();
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  var FirstnameController = TextEditingController();
  var LastnameController = TextEditingController();
  var InvitationCodeController = TextEditingController();

  bool islogin = false;
  bool iswebView = false;
  bool isPaymentLoading=true;
  bool isRegisterLoading = true;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _platformVersion = 'Unknown';
  Future<void> initformState() async {
    String platformVersion;


    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);

      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:':'Failed to get platform version.'
      };
    }

    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build){
    return <String, dynamic>{
      'version.release': build.version.release,
      'fingerprint': build.host,
      'id':build.id,
      'type':build.type,
      'device':build.device,
      'model':build.model,
      'hardware':build.hardware,
      'product':build.product,
      'brand':build.brand,
      'supported':build.supported32BitAbis

    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
      'id':data.identifierForVendor
    };
  }

  String phoneNumber, verificationId;
  String otp, authStatus = "";
  Future<void> verifyPhoneNumber(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
        });
      },
      verificationFailed: (authException) {
        setState(() {
          authStatus = "Authentication failed";
        });
      },
      codeSent: (String verId, [int forceCodeResent]) {
        verificationId = verId;
        setState(() {
          authStatus = "OTP has been successfully send";
        });

      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() {
          authStatus = "TIMEOUT";
        });
      },
    );
  }

  @override
  void initState() {
    fbm.getToken().then((token){
      print(token);
      fcmtoken = token;
    });
    initPlatformState();
    initformState();

    super.initState();
  }


  String access_token = Cachehelper.getData(key: "token");
  bool isLoading = true;

  Checkout(payload,token)async{
    print(token);
    setState(() {
      isPaymentLoading =false;
    });
    http.Response response = await http.post(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${token}',},
        body:jsonEncode(payload)
    ).then((value){
      var responsebody = jsonDecode(value.body);
      print('--------------------------------------------------------------------');
      printFullText('result:${responsebody.toString()}');
      setState(() {
        isPaymentLoading = true;
        navigateTo(context, PaymentPage(refCode:responsebody['order_ref']));
      });
    }).catchError((onError){

    });
    return response;
  }
  @override
  Widget build(BuildContext context) {
    double latitud = Cachehelper.getData(key: "latitude");
    double longitud = Cachehelper.getData(key: "longitude");
    String MyLocation = Cachehelper.getData(key: "myLocation");
    String device_id = Cachehelper.getData(key:"deviceId");



    return BlocProvider(
        create: (context)=>StoreCubit(),
        child: BlocConsumer<StoreCubit,ShopStates>(
            listener: (context,state){
            if(state is MyorderSucessfulState){
              navigateTo(context, Order(order: state.order));
            }
            },
            builder: (context,state){
              String access_token = Cachehelper.getData(key: "fcmtoken");
              var cubit = StoreCubit.get(context);
              return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                  ),
                  backgroundColor: Colors.white,
                  body:iswebView==false? Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          height(50),
                          Form(
                            key: fromkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text('اهلا بك في كناري',style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Hind"
                                  ),),
                                ),
                                height(15),
                                islogin==false?Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: buildTextFiled(
                                    Validat: (value) {
                                      RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
                                      if (value == null || value.isEmpty) {
                                        return 'الاسم الأول لا يجب أن تكون فارغة ';
                                      }
                                      if(arabicRegex.hasMatch(value)){
                                        return 'الرجاء إدخال الاسم الأول بالفرنسية';
                                      }
                                      return null;
                                    },
                                    onEditingComplete: (){
                                      if (fromkey.currentState.validate()) {
                                        fromkey.currentState.save();
                                      }
                                    },
                                    controller: FirstnameController,
                                    keyboardType: TextInputType.name,
                                    hintText:DemoLocalization.of(context).getTranslatedValue('first_name'),
                                    valid:DemoLocalization.of(context).getTranslatedValue('first_name'),
                                  ),
                                ):height(0),
                                islogin==false? height(25):height(0),
                                islogin==false? Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: buildTextFiled(
                                    Validat: (value) {
                                      RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
                                      if (value == null || value.isEmpty) {
                                        return lg=='ar'?'الاسم العائلة لا يجب أن تكون فارغة ':"Le nom de famille ne doit pas être vide";
                                      }
                                      if(arabicRegex.hasMatch(value)){
                                        return lg=='ar'?'الرجاء إدخال الاسم العائلة بالفرنسية':"Veuillez entrer votre nom de famille en français";
                                      }
                                      return null;
                                    },
                                    onEditingComplete: (){
                                      if (fromkey.currentState.validate()) {
                                        fromkey.currentState.save();
                                      }
                                    },
                                    controller: LastnameController,
                                    keyboardType: TextInputType.name,
                                    hintText:DemoLocalization.of(context).getTranslatedValue('last_name'),
                                    valid:DemoLocalization.of(context).getTranslatedValue('last_name'),
                                  ),
                                ):height(0),
                                islogin==false?height(25):height(0),
                                islogin==false?
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: buildTextFiled(
                                    suffixIcon:state is ValidateInvitationLoadingState?CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        maxRadius: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: CircularProgressIndicator(color: Colors.blue,),
                                        )):ValideIcon(StoreCubit.get(context).isValid),
                                    inputFormatters:[
                                      new LengthLimitingTextInputFormatter(6),
                                    ],
                                    onchange: (value)async{
                                      if(value.length==6){
                                        StoreCubit.get(context).ValidateInvitation(value);
                                      }else{
                                        StoreCubit.get(context).isValid = null;
                                        setState(() {

                                        });
                                      }
                                    },
                                    controller: InvitationCodeController,
                                    keyboardType: TextInputType.name,
                                    hintText: '${DemoLocalization.of(context).getTranslatedValue('code_invite')} ${DemoLocalization.of(context).getTranslatedValue('Optionnel')} ',
                                  ),

                                ):height(0),
                                StoreCubit.get(context).isValid == null || StoreCubit.get(context).isValid==true ?height(0):height(15),
                                StoreCubit.get(context).isValid == false ? Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child:StoreCubit.get(context).isValid == null?SizedBox(height: 0):
                                  Text(DemoLocalization.of(context).getTranslatedValue('code_invite_invalide'),style: TextStyle(
                                    color: AppColor,
                                    fontSize: 12.5,
                                  ),
                                  )
                                ):SizedBox(height: 0),
                                height(25),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 57,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: Colors.grey[300],
                                                  width: 1.5)),
                                          child: CountryListPick(
                                              theme: CountryTheme(
                                                initialSelection:
                                                'Choisir un pays',
                                                labelColor: AppColor,
                                                alphabetTextColor:
                                                AppColor,
                                                alphabetSelectedTextColor:
                                                Colors.red,
                                                alphabetSelectedBackgroundColor:
                                                Colors.grey[300],
                                                isShowFlag: false,
                                                isShowTitle: false,
                                                isShowCode: true,
                                                isDownIcon: false,
                                                showEnglishName: true,
                                              ),
                                              appBar: AppBar(
                                                backgroundColor:
                                                AppColor,
                                                title:
                                                Text('Choisir un pays',
                                                  style: TextStyle(color: Colors.white),),
                                              ),
                                              initialSelection: '+212',
                                              onChanged: (CountryCode code) {
                                                print(code.name);
                                                print(code.dialCode);
                                                phoneCode = code.dialCode;
                                              },
                                              useUiOverlay: false,
                                              useSafeArea: false),
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        flex: 3,
                                        child: buildTextFiled(
                                            Validat: (value) {
                                              if (value == null || value.isEmpty) {
                                                return lg=='ar'?'رقم الهاتف لا يجب أن تكون فارغة ':"Le numéro de téléphone ne doit pas être vide";
                                              }
                                              return null;
                                            },
                                            onEditingComplete:(){
                                              if (fromkey.currentState.validate()) {
                                                fromkey.currentState.save();
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            hintText:DemoLocalization.of(context).getTranslatedValue('num_phone'),
                                            valid:DemoLocalization.of(context).getTranslatedValue('num_phone'),
                                            onSaved: (number) {
                                              if (number.length == 9) {
                                                phoneNumber = "${phoneCode}${number}";
                                              } else {
                                                final replaced = number.replaceFirst(
                                                    RegExp('0'), '');
                                                phoneNumber = "${phoneCode}${replaced}";
                                                print(phoneNumber);
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                height(25),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (fromkey.currentState.validate()) {
                                        fromkey.currentState.save();
                                        if(islogin==false){
                                          if(phone_number_verification){
                                            verifyPhoneNumber(context);
                                            iswebView=true;
                                            setState(() {

                                            });
                                          }else{
                                            setState(() {
                                              isRegisterLoading = false;
                                            });
                                            fbm.getToken().then((token)async{
                                              fcmtoken = token;
                                              var Jsondata = {
                                                "first_name":FirstnameController.text,
                                                "last_name":LastnameController.text,
                                                "phone":"${phoneNumber}",
                                                "invitation_code":InvitationCodeController.text,
                                                "device":{
                                                  "token_firebase":"${fcmtoken}",
                                                  "device_id":"z0f33s43p4",
                                                  "appName":"superApp",
                                                  "device_name":Platform.isAndroid?"android":"iphone",
                                                  "ip_address":"192.168.1.1",
                                                  "mac_address":"192.168.1.1",

                                                }
                                              };
                                              await http.post(
                                                  Uri.parse('https://www.api.canariapp.com/v1/client/register'),
                                                  headers:{'Content-Type':'application/json','Accept':'application/json',},
                                                  body:jsonEncode(Jsondata)
                                              ).then((value) {
                                                var responsebody = jsonDecode(value.body);
                                                Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                                Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                                Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                                Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                                Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                                setState(() {
                                                  isRegisterLoading = true;
                                                  if(widget.paymentMethod=='cash'){
                                                    List<Map<String, dynamic>> modifiedList =[{
                                                      "restaurant": StoreName,
                                                      "address": MyLocation,
                                                      "totalPrice":widget.total,
                                                      "deliveryPrice":deliveryPrice,
                                                      "weather_fee":widget.wether_fee,
                                                      "service_fee":widget.service_fee
                                                    }];
                                                    navigateTo(context, AnimatedListView(
                                                      coupon:widget.coupon,
                                                      method_payment: widget.paymentMethod,
                                                      order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                      note:widget.NoteController.text,CouponController:widget.CouponController.text,));
                                                  }else{
                                                    cubit.UpdateProfile({
                                                      "email":"${widget.emailController.text}"
                                                    }).then((value) {
                                                      isloading = true;
                                                      List<Map<String, dynamic>> modifiedList =[{
                                                        "restaurant": StoreName,
                                                        "address": MyLocation,
                                                        "totalPrice":widget.total,
                                                        "deliveryPrice":deliveryPrice,
                                                        "weather_fee":widget.wether_fee,
                                                        "service_fee":widget.service_fee
                                                      }];
                                                      navigateTo(context, AnimatedListView(
                                                        coupon: widget.coupon,
                                                        method_payment: widget.paymentMethod,
                                                        order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                        note: widget.NoteController.text,CouponController:widget.CouponController.text,));
                                                    }).catchError((onError){
                                                    });
                                                  }


                                                });
                                              }).catchError((error){
                                                setState(() {
                                                  Fluttertoast.showToast(
                                                      msg: "لديك حساب قم بتسجيل دخول",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.BOTTOM,
                                                      webShowClose:false,
                                                      backgroundColor: AppColor,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0
                                                  );
                                                  isloading =true;
                                                  islogin = true;
                                                  isRegisterLoading = true;
                                                });
                                              });
                                            });
                                          }
                                        }
                                        else{
                                          verifyPhoneNumber(context);
                                          iswebView=true;
                                          setState(() {

                                          });
                                        }

                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppColor
                                      ),
                                      child:isRegisterLoading?Center(
                                          child: isloading ?isPaymentLoading? Text('التالي',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ) : CircularProgressIndicator(color: Colors.white):CircularProgressIndicator(color: Colors.white)
                                      ):Center(child: CircularProgressIndicator(color: Colors.white)),
                                      height: 58,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                height(6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    islogin==false? Text('لدي حساب !'):Text('ليس لدي حساب !'),
                                    islogin==false? TextButton(onPressed:(){
                                      setState(() {
                                        islogin = true;
                                      });
                                    },
                                        child: Text('تسجيل الدخول', style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),)):
                                    TextButton(onPressed:(){
                                      setState(() {
                                        islogin = false;
                                      });
                                    },
                                        child: Text('إنشاء حساب', style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):Stack(
                    children:<Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'تَحَقّق',
                                style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          height(6),
                          Text('انتضر قليلا ثم أدخل الرمز الذي أرسلناه لك للتو على رقمك ', style: TextStyle(fontSize: 17.0,color: Colors.grey[500]),textAlign: TextAlign.center),
                          TextButton(onPressed: (){
                            iswebView = false;
                            setState(() {

                            });
                          }, child: Text('تغيير رقم',style: TextStyle(
                              color: AppColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.8
                          ),)),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: VerificationCode(
                              fillColor: Colors.grey[100],
                              fullBorder: true,
                              underlineUnfocusedColor: Colors.grey[100],
                              textStyle: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.number,
                              underlineColor: AppColor,
                              length: 6,
                              cursorColor: Colors.blue,
                              margin: const EdgeInsets.all(5),
                              onCompleted: (String value) {
                                setState(() async {
                                  code = value;
                                  isLoading = false;
                                  await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                                    if(islogin){
                                      if(FirebaseAuth.instance.currentUser!=null){
                                        fbm.getToken().then((token)async{
                                          fcmtoken = token;
                                          var Jsondata = {
                                            "phone": "${phoneNumber}",
                                            "uid": "${FirebaseAuth.instance.currentUser.uid}",
                                            "device":{
                                              "token_firebase":"${fcmtoken}",
                                              "device_id":"z0f33s43p4",
                                              "device_name":Platform.isAndroid?"android":"iphone",
                                              "ip_address":"192.168.1.1",
                                              "mac_address":"192.168.1.1",
                                              "appName":"superApp",
                                            }
                                          };
                                          await http.post(
                                              Uri.parse('https://www.api.canariapp.com/v1/client/login'),
                                              headers:{'Content-Type':'application/json','Accept':'application/json',},
                                              body:jsonEncode(Jsondata)
                                          ).then((value) {

                                            var responsebody = jsonDecode(value.body);
                                            print('======================================================================');
                                            printFullText(responsebody.toString());
                                            print('======================================================================');
                                            Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                            Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                            Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                            Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                            Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                            setState(() {
                                              if(widget.paymentMethod=='cash'){
                                                List<Map<String, dynamic>> modifiedList =[{
                                                  "restaurant": StoreName,
                                                  "address": MyLocation,
                                                  "totalPrice":widget.total,
                                                  "deliveryPrice":deliveryPrice,
                                                  "weather_fee":widget.wether_fee,
                                                  "service_fee":widget.service_fee
                                                }];
                                                navigateTo(context, AnimatedListView(
                                                  coupon: widget.coupon,
                                                  method_payment: widget.paymentMethod,
                                                  order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                  note: widget.NoteController.text,CouponController:widget.CouponController.text,));
                                              }else{
                                                cubit.UpdateProfile({
                                                  "email":"${widget.emailController.text}"
                                                }).then((value) {
                                                  isloading = true;
                                                  List<Map<String, dynamic>> modifiedList =[{
                                                    "restaurant": StoreName,
                                                    "address": MyLocation,
                                                    "totalPrice":widget.total,
                                                    "deliveryPrice":deliveryPrice,
                                                    "weather_fee":widget.wether_fee,
                                                    "service_fee":widget.service_fee
                                                  }];
                                                  navigateTo(context, AnimatedListView(
                                                    method_payment: widget.paymentMethod,
                                                    coupon: widget.coupon,
                                                    order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                    note: widget.NoteController.text,CouponController:widget.CouponController.text,));
                                                }).catchError((onError){
                                                });
                                              }
                                            });
                                          }).catchError((error){
                                            setState(() {
                                              Fluttertoast.showToast(
                                                  msg: "ليس لديك حساب قم بانشاء واحد",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  webShowClose:false,
                                                  backgroundColor: AppColor,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                              isloading =true;
                                              islogin = false;
                                              iswebView = false;
                                            });
                                          });
                                        });
                                      }
                                    }else{
                                      fbm.getToken().then((token)async{
                                        fcmtoken = token;
                                        var Jsondata = {
                                          "first_name":FirstnameController.text,
                                          "last_name":LastnameController.text,
                                          "phone":"${phoneNumber}",
                                          "invitation_code":InvitationCodeController.text,
                                          "device":{
                                            "token_firebase":"${fcmtoken}",
                                            "device_id":"z0f33s43p4",
                                            "device_name":Platform.isAndroid?"android":"iphone",
                                            "ip_address":"192.168.1.1",
                                            "mac_address":"192.168.1.1",
                                            "appName":"superApp",
                                          }
                                        };
                                        await http.post(
                                            Uri.parse('https://www.api.canariapp.com/v1/client/register'),
                                            headers:{'Content-Type':'application/json','Accept':'application/json',},
                                            body:jsonEncode(Jsondata)
                                        ).then((value) {
                                          var responsebody = jsonDecode(value.body);
                                          Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                          Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                          Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                          Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                          Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                          setState(() {
                                            if(widget.paymentMethod=='cash'){
                                              List<Map<String, dynamic>> modifiedList =[{
                                                "restaurant": StoreName,
                                                "address": MyLocation,
                                                "totalPrice":widget.total,
                                                "deliveryPrice":deliveryPrice,
                                                "weather_fee":widget.wether_fee,
                                                "service_fee":widget.service_fee
                                              }];
                                              navigateTo(context, AnimatedListView(
                                                coupon:widget.coupon,
                                                method_payment: widget.paymentMethod,
                                                order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                note:widget.NoteController.text,CouponController:widget.CouponController.text,));
                                            }else{
                                              cubit.UpdateProfile({
                                                "email":"${widget.emailController.text}"
                                              }).then((value) {
                                                isloading = true;
                                                List<Map<String, dynamic>> modifiedList =[{
                                                  "restaurant": StoreName,
                                                  "address": MyLocation,
                                                  "totalPrice":widget.total,
                                                  "deliveryPrice":deliveryPrice,
                                                  "weather_fee":widget.wether_fee,
                                                  "service_fee":widget.service_fee
                                                }];
                                                navigateTo(context, AnimatedListView(
                                                  coupon: widget.coupon,
                                                  method_payment: widget.paymentMethod,
                                                  order:modifiedList,myLocation:MyLocation,total:widget.total,deliveryPrice:deliveryPrice,routing: "register",
                                                  note: widget.NoteController.text,CouponController:widget.CouponController.text,));
                                              }).catchError((onError){
                                              });
                                            }


                                          });
                                        }).catchError((error){
                                          setState(() {
                                            Fluttertoast.showToast(
                                                msg: "لديك حساب قم بتسجيل دخول",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                webShowClose:false,
                                                backgroundColor: AppColor,
                                                textColor: Colors.white,
                                                fontSize: 16.0
                                            );
                                            isloading =true;
                                            islogin = true;
                                            iswebView = false;
                                          });
                                        });
                                      });
                                    }

                                  });

                                });
                              },
                              onEditing: (bool value) {
                                setState(() {
                                  onEditing = value;

                                });
                                if (!onEditing) FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          height(10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('لم تتلق رمز؟ '),
                              TextButton(onPressed: (){
                                verifyPhoneNumber(context);
                              }, child: Text('إعادة إرسال',style: TextStyle(
                                  color: AppColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.8
                              ),)),

                            ],
                          ),

                          height(6),
                          GestureDetector(
                            onTap: (){
                              isLoading = false;
                              FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value) async {
                                await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                                  if(islogin){
                                    if(FirebaseAuth.instance.currentUser!=null){
                                      fbm.getToken().then((token)async{
                                        fcmtoken = token;
                                        var Jsondata = {
                                          "phone": "${phoneNumber}",
                                          "uid": "${FirebaseAuth.instance.currentUser.uid}",
                                          "device":{
                                            "token_firebase":"${fcmtoken}",
                                            "device_id":"z0f33s43p4",
                                            "device_name":Platform.isAndroid?"android":"iphone",
                                            "ip_address":"192.168.1.1",
                                            "mac_address":"192.168.1.1",
                                            "appName":"superApp",
                                          }
                                        };
                                        await http.post(
                                            Uri.parse('https://www.api.canariapp.com/v1/client/login'),
                                            headers:{'Content-Type':'application/json','Accept':'application/json',},
                                            body:jsonEncode(Jsondata)
                                        ).then((value) {
                                          var responsebody = jsonDecode(value.body);
                                          printFullText(responsebody.toString());
                                          Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                          Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                          Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                          Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                          Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                          setState(() {
                                            Navigator.of(context).pop();
                                          });
                                        }).catchError((error){
                                          setState(() {
                                            Fluttertoast.showToast(
                                                msg: "ليس لديك حساب قم بانشاء واحد",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                webShowClose:false,
                                                backgroundColor: AppColor,
                                                textColor: Colors.white,
                                                fontSize: 16.0
                                            );
                                            isloading =true;
                                            islogin = false;
                                            iswebView = false;
                                          });
                                        });
                                      });
                                    }
                                  }else{
                                    fbm.getToken().then((token)async{
                                      fcmtoken = token;
                                      var JsonData = {
                                        "first_name":FirstnameController.text,
                                        "last_name":LastnameController.text,
                                        "phone":"${phoneNumber}",
                                        "invitation_code":InvitationCodeController.text,
                                        "device":{
                                          "token_firebase":"${fcmtoken}",
                                          "device_id":"z0f33s43p4",
                                          "device_name":Platform.isAndroid?"android":"iphone",
                                          "ip_address":"192.168.1.1",
                                          "mac_address":"192.168.1.1",
                                          "appName":"superApp",
                                        }
                                      };
                                      await http.post(
                                          Uri.parse('https://www.api.canariapp.com/v1/client/register'),
                                          headers:{'Content-Type':'application/json','Accept':'application/json',},
                                          body:jsonEncode(JsonData)
                                      ).then((value) {
                                        var responsebody = jsonDecode(value.body);
                                        Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                        Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                        Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                        Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                        Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                        setState(() {
                                          Navigator.of(context).pop();
                                        });
                                      }).catchError((error){
                                        setState(() {
                                          Fluttertoast.showToast(
                                              msg: "لديك حساب قم بتسجيل دخو",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              webShowClose:false,
                                              backgroundColor: AppColor,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                          isloading = true;
                                          islogin = false;
                                          iswebView = false;
                                        });
                                      });
                                    });
                                  }

                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20,right: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color:code!=null?AppColor:Colors.grey[400]
                                ),
                                child: Center(
                                    child: isLoading ? Text('تاكيد',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ) : CircularProgressIndicator(color: Colors.white)),
                                height: 58,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          height(20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () async => await launch(
                                      "https://wa.me/+212619157091?text= مشكلتي : "),
                                  child: Text('تواصل معنا',style: TextStyle(
                                      color: AppColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.8
                                  ),)),
                              Text('اذا واجهت اي مشكلة في تسجيل'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
              );},
        ),
    );
  }

}





Widget buildTextFiled(
    {String hintText,
      TextEditingController controller,
      Function ontap,
      String valid,
      Function onSaved,
      Function Validat,
      Function onEditingComplete,
      TextInputType keyboardType,
      Function onchange,
      List<TextInputFormatter> inputFormatters,
      Widget suffixIcon,
    }) {
  return TextFormField(
    onChanged:onchange,
    onEditingComplete:onEditingComplete,
    keyboardType: keyboardType,
    onSaved: onSaved,
    validator: Validat,
    onTap: ontap,
    inputFormatters:inputFormatters,
    controller: controller,
    decoration: InputDecoration(

      suffixIcon:suffixIcon,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 19.0,horizontal: 10),
        filled: true,
        fillColor:Colors.grey[50],
        hintText: '${hintText}',
        hintStyle: TextStyle(color: Color(0xFF7B919D), fontSize: 14)),
  );
}
