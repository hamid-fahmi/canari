import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopapp/Layout/HomeLayout/layoutScreen.dart';
import 'package:shopapp/modules/pages/Static/couponPage.dart';
import 'package:shopapp/modules/pages/PrivacyPolicy/privacyPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/modules/Register/register.dart';
import 'package:shopapp/modules/pages/Order/myordersPage.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../class/langauge.dart';
import '../../localization/demo_localization.dart';
import '../../localization/localization_constants.dart';
import '../../main.dart';
import '../../modules/pages/Static/share.dart';
import '../../modules/pages/Static/support_service.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/remote/cachehelper.dart';
import '../shopcubit/storecubit.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

bool isloading = true;
String phoneNumber;
String phoneCode = '+212';
bool onEditing = true;


final GlobalKey<FormState> otpkey = GlobalKey<FormState>();
final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
class Account extends StatefulWidget {
  final String routing;
  const Account({Key key, this.routing}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String selectelang;
  String language = Cachehelper.getData(key:"langugeCode");

  void _changeLanguge(Language lang) async{
    Locale _temp = await setLocale(lang.languageCode);
    MyApp.setLocale(context, _temp);
    setState(() {
      lg = lang.languageCode;
      Cachehelper.sharedPreferences.setString("langugeCode",lang.languageCode);
      print('lang is :${lg}');
    });
  }

  var fbm = FirebaseMessaging.instance;
  String code;
  String fcmtoken='';
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  var FirstnameController = TextEditingController();
  var InvitationCodeController = TextEditingController();
  var LastnameController = TextEditingController();
  var PhoneController = TextEditingController();
  var otpController = TextEditingController();
  bool islogin = false;
  bool isupdate = false;
  bool iswebview = false;
  bool isProfileUpdate = true;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer timer;
  bool isLoading=true;
  bool isRegisterLoading=true;
  String phoneNumber, verificationId;
  String otp, authStatus = "";

  void start(){
    timer = Timer.periodic(Duration(milliseconds:70), (_){
      if(seconds>0){
        seconds--;
        setState(() {
        });
      }
  });
  }
  Future<void> verifyPhoneNumber(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
          print('${authStatus}');

        });
      },
      verificationFailed: (authException) {
        setState(() {
          authStatus = authException.message;
          print(authStatus);
          Fluttertoast.showToast(
              msg: "فشلت محاولة حصول على كود يرجى تواصل معنا",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor:AppColor,
              textColor: Colors.white,
              fontSize: 16.0
          );

          print('${authStatus}');
        });
      },
      codeSent: (String verId, [int forceCodeResent]) {
        verificationId = verId;
        setState(() {
          authStatus = "OTP has been successfully send";
          print('${authStatus}');
        });

      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }



  @override
  void initState() {
    selectelang = language=="ar"?'العربية':"Français";
    super.initState();
  }

  

  

  @override
  Widget build(BuildContext context) {
    String firstname = Cachehelper.getData(key: "first_name");
    String lastname = Cachehelper.getData(key: "last_name");
    String phone = Cachehelper.getData(key: "phone");

    return BlocProvider(
      create: (context)=>StoreCubit()..GetProfile(),
      child: BlocConsumer<StoreCubit,ShopStates>(
        listener: (context,state){
        },
        builder: (context,state){
          FirstnameController.text = firstname;
          LastnameController.text = lastname;

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 20,
            ),
            backgroundColor: Colors.white,
            body: firstname != null && isupdate==false?
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:0,bottom:0,right:0),
                      child: Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children: [
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Container(
                               height:50,
                               width:50,
                               decoration:BoxDecoration(
                                 shape: BoxShape.circle,
                                 color:Color(0xfff6cfd2),
                                 border: Border.all(
                                   width:1.2,
                                   color:Colors.white,
                                 ),
                               ),
                               child:Center(child: Text('${firstname[0].toUpperCase()}${lastname[0].toUpperCase()}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color:AppColor),)),
                             ),
                             width(10),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: [
                                 Text('${firstname} ${lastname}',style: TextStyle(fontSize: 16,color: Colors.black)),
                                 Text('${phone}',style: TextStyle(fontSize: 10,color: Colors.grey),textDirection:TextDirection.ltr),
                               ],
                             ),
                           ],
                         ),
                         Padding(
                            padding: const EdgeInsets.only(top: 20,bottom: 10,right: 20),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  isupdate = true;
                                });
                              },
                              child: Container(
                                height: 20,
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit,size: 18),
                                    width(10),
                                    Text(DemoLocalization.of(context).getTranslatedValue('Modifier_le_compte'),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    height(20),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10,left: 0),
                      child: GestureDetector(
                        onTap: (){
                          navigateTo(context, MyorderPage());
                        },
                        child: Container(
                          height: 20,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Icon(Icons.fastfood),
                              width(10),
                              Text(DemoLocalization.of(context).getTranslatedValue('Mes_demandes'),style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                          width:double.infinity,
                        ),
                      ),
                    ),
                    coupon_page?Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10),
                      child: GestureDetector(
                        onTap: (){
                          navigateTo(context, CoupondPage());
                        },
                        child: Row(
                          children: [
                            Icon(Icons.turned_in_not_sharp),
                            width(10),
                            Text(DemoLocalization.of(context).getTranslatedValue('Mes_Coupons'),style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ):height(0),
                    share_app?Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10),
                      child: GestureDetector(
                        onTap: (){
                          navigateTo(context, Share());
                        },
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            width(10),
                            Text(DemoLocalization.of(context).getTranslatedValue('Partagez_et_gagnez'),style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ):height(0),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10),
                      child: GestureDetector(
                        onTap: (){
                          navigateTo(context, SupportService());
                        },
                        child: Container(
                          height: 20,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.whatsapp),
                              width(10),
                              Text(DemoLocalization.of(context).getTranslatedValue('Contactez_nous'),style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10),
                      child: GestureDetector(
                        onTap: (){
                          navigateTo(context,PrivacyPage());
                        },
                        child: Row(
                          children: [
                            Icon(Icons.privacy_tip_outlined),
                            width(10),
                            Text(DemoLocalization.of(context).getTranslatedValue('Confidentiality'),style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 10,right: 10),
                      child: GestureDetector(
                        onTap: (){
                        Cachehelper.removeData(key: 'token');
                        Cachehelper.removeData(key: 'first_name');
                        Cachehelper.removeData(key: 'last_name');
                        Cachehelper.removeData(key: 'phone');
                        Cachehelper.removeData(key: 'deviceId');

                        if(widget.routing=='homepage'){
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                            latitude: latitude,
                            longitude: longitude,
                            myLocation: myLocation,
                          )), (route) => false);
                        }
                        if(widget.routing=='homelayout'){
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                            latitude: latitude,
                            longitude: longitude,
                            myLocation: myLocation,
                          )), (route) => false);
                        }
                        },
                        child: Container(
                          height: 20,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              width(10),
                              Text(DemoLocalization.of(context).getTranslatedValue('Déconnexion'),style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                          width: double.infinity,
                        ),
                      ),
                    ),
                    height(20),
                    // Container(
                    //     height: 45,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color:Colors.grey[300],width: 1.5),
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child:Padding(
                    //       padding:
                    //       const EdgeInsets.only(left: 5, top: 0, right: 5),
                    //       child: DropdownButton(
                    //         onChanged: (language) async {
                    //           await _changeLanguge(language);
                    //           setState(() {
                    //             if(widget.routing=='homepage'){
                    //               Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                    //                 latitude: latitude,
                    //                 longitude: longitude,
                    //                 myLocation: myLocation,
                    //               )), (route) => false);
                    //             }
                    //             if(widget.routing=='homelayout'){
                    //               Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                    //                 latitude: latitude,
                    //                 longitude: longitude,
                    //                 myLocation: myLocation,
                    //               )), (route) => false);
                    //             }
                    //           });
                    //         },
                    //
                    //         icon:Padding(
                    //           padding:
                    //           const EdgeInsets.only(top: 0, right: 0, left: 0),
                    //           child: Icon(
                    //               Icons.keyboard_arrow_down,
                    //               color:Colors.black
                    //           ),
                    //         ),
                    //         underline: SizedBox(),
                    //         isExpanded: true,
                    //         hint:Row(
                    //           children:[
                    //             width(5),
                    //             Icon(
                    //               Icons.language,
                    //               color:Colors.black,
                    //             ),
                    //             SizedBox(
                    //               width: 10,
                    //             ),
                    //             Container(
                    //               height: 30,
                    //               width: 2,
                    //               color:Colors.grey[300],
                    //             ),
                    //             width(10),
                    //             Text(
                    //               "${selectelang}",
                    //               style: TextStyle(color: Colors.black,fontSize: 13.5),
                    //             ),
                    //           ],
                    //         ),
                    //         items: Language.languageList()
                    //             .map<DropdownMenuItem<Language>>((lang){
                    //               print(lang);
                    //           return DropdownMenuItem(
                    //             value:lang,child:Text(lang.name),
                    //           );
                    //         }
                    //         ).toList(),
                    //       ),
                    //     )),
                  ],
                ),
              ),
            ):
            iswebview == false ?
            SingleChildScrollView(
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20,left: 20),
                              child: Text(isupdate==false?'${DemoLocalization.of(context).getTranslatedValue('bienvenue')}':'${DemoLocalization.of(context).getTranslatedValue('edit_account')}',style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Hind"
                              ),),
                            ),
                            height(20),
                            islogin==false?Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: buildTextFiled(
                                Validat: (value) {
                                  RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
                                  if (value == null || value.isEmpty) {
                                    return lg=='ar'?'الاسم الأول لا يجب أن تكون فارغة ':"Le prénom ne doit pas être vide";
                                  }
                                  if(arabicRegex.hasMatch(value)){
                                    return lg=='ar'?'الرجاء إدخال الاسم الأول بالفرنسية':"Veuillez entrer votre prénom en français";
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
                                valid:DemoLocalization.of(context).getTranslatedValue('last_name'),
                                keyboardType: TextInputType.name,
                                hintText:DemoLocalization.of(context).getTranslatedValue('last_name'),
                              ),
                            ):height(0),
                            height(25),
                            isupdate==false?
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
                                        onEditingComplete: (){
                                          if (fromkey.currentState.validate()) {
                                            fromkey.currentState.save();
                                          }
                                        },
                                      controller: PhoneController,
                                        keyboardType: TextInputType.number,
                                        hintText:DemoLocalization.of(context).getTranslatedValue('num_phone'),
                                        valid:DemoLocalization.of(context).getTranslatedValue('num_phone'),
                                        onSaved: (number) {
                                          if (number.length == 9) {
                                            phoneNumber = "${phoneCode}${number}";
                                          } else {
                                            final replaced = number.replaceFirst(RegExp('0'), '');
                                            phoneNumber = "${phoneCode}${replaced}";
                                          }
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ):height(0),
                            islogin==false?height(25):height(0),
                            islogin==false?
                            isupdate==false?Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
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

                               ),
                               islogin==false? height(15):height(0),
                               StoreCubit.get(context).isValid == null?height(0):Padding(
                                 padding: const EdgeInsets.only(left: 20, right: 20),
                                 child: StoreCubit.get(context).isValid==false?Text(DemoLocalization.of(context).getTranslatedValue('code_invite_invalide'),style: TextStyle(
                                   color: AppColor,
                                   fontSize: 12.5,
                                 ),
                                 )
                                     :height(0),
                               )
                             ],
                           ):height(0):height(0),

                            height(0),
                            isupdate==false?height(25):height(0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: GestureDetector(
                                onTap: (){
                                if (fromkey.currentState.validate()) {
                                    fromkey.currentState.save();
                                    if(isupdate){
                                     isProfileUpdate = false;
                                     StoreCubit.get(context).UpdateProfile({
                                        "first_name":FirstnameController.text,
                                        "last_name":LastnameController.text,
                                      }).then((value){
                                        setState(() {
                                          isProfileUpdate = true;
                                        });
                                        isupdate = false;
                                        isLoading = false;
                                        if(widget.routing=='homepage'){
                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                            latitude: latitude,
                                            longitude: longitude,
                                            myLocation: myLocation,
                                          )), (route) => false);
                                        }
                                        if(widget.routing=='homelayout'){
                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                            latitude: latitude,
                                            longitude: longitude,
                                            myLocation: myLocation,
                                          )), (route) => false);
                                        }
                                      });
                                    }else{
                                      if(islogin==false){
                                        if(phone_number_verification){
                                          verifyPhoneNumber(context);
                                          iswebview =true;
                                        }else{
                                            setState((){
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
                                                "device_name":Platform.isAndroid?"android":"iphone",
                                                "ip_address":"192.168.1.1",
                                                "mac_address":"192.168.1.1",
                                                "appName":"superApp",
                                              }
                                            };
                                            print(Jsondata);
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
                                                if(widget.routing=='homepage'){
                                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                                    latitude: latitude,
                                                    longitude: longitude,
                                                    myLocation: myLocation,
                                                  )), (route) => false);
                                                }
                                                if(widget.routing=='homelayout'){
                                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                                    latitude: latitude,
                                                    longitude: longitude,
                                                    myLocation: myLocation,
                                                  )), (route) => false);
                                                }
                                              });
                                            }).catchError((error){
                                              setState(() {
                                                print(error.toString());
                                                // Fluttertoast.showToast(
                                                //     msg:error.toString(),
                                                //     toastLength: Toast.LENGTH_SHORT,
                                                //     gravity: ToastGravity.BOTTOM,
                                                //     webShowClose:false,
                                                //     backgroundColor: AppColor,
                                                //     textColor: Colors.white,
                                                //     fontSize: 16.0
                                                // );
                                                isLoading = true;
                                                isRegisterLoading = true;
                                                islogin = false;
                                              });
                                            });
                                          });
                                        }
                                      }
                                      else{
                                        verifyPhoneNumber(context);
                                        iswebview =true;
                                      }
                                    }
                                    setState(() {

                                    });
                                }

                                  },
                                child:Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color:AppColor
                                  ),
                                  child:isRegisterLoading?isProfileUpdate?Center(
                                      child: isloading ? Text(isupdate==false?'${DemoLocalization.of(context).getTranslatedValue('next')}':'${DemoLocalization.of(context).getTranslatedValue('edit')}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ) : CircularProgressIndicator(color: Colors.white)):Center(child: CircularProgressIndicator(color: Colors.white)):Center(child: CircularProgressIndicator(color: Colors.white)),
                                  height: 58,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                        height(10),
                        isupdate==false?Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            islogin==false? Text(DemoLocalization.of(context).getTranslatedValue('account_have')):Text(DemoLocalization.of(context).getTranslatedValue('dont_have_account')),
                            islogin==false? TextButton(onPressed:(){
                              setState(() {
                                islogin = true;
                              });
                            },
                            child:Text(DemoLocalization.of(context).getTranslatedValue('Se_connecter'), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16),)):
                            TextButton(onPressed:(){
                              setState(() {
                                islogin = false;
                              });
                            },
                                child: Text(DemoLocalization.of(context).getTranslatedValue('Se_connecter'), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16),))
                          ],
                        ):height(0),

                      ],
                    ),
                  ),
                ],
              ),
            ):lg=='ar'?Stack(
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
                    Text('انتضر قليلا ثم أدخل الرمز الذي أرسلناه لك للتو على رقمك', style: TextStyle(fontSize: 17.0,color: Colors.grey[500]),textAlign: TextAlign.center),
                    TextButton(onPressed: (){
                      iswebview = false;
                      setState(() {

                      });
                    }, child: Text('تغيير رقم',
                      style: TextStyle(
                      color: AppColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.8
                    ),)),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: VerificationCode(
                        fillColor: Colors.grey[100],
                        fullBorder:true,
                        underlineUnfocusedColor: Colors.grey[100],
                        textStyle: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.number,
                        underlineColor: AppColor,
                        length: 6,
                        cursorColor: AppColor,
                        margin: const EdgeInsets.all(5),
                        onCompleted: (String value)async{
                          code = value;
                          isLoading = false;
                          await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                            if(islogin){
                              if(FirebaseAuth.instance.currentUser!=null){
                                fbm.getToken().then((token)async{
                                  var Jsondata = {
                                    "phone": "${phoneNumber}",
                                    "uid":"${FirebaseAuth.instance.currentUser.uid}",
                                    "device":{
                                      "token_firebase":"${fcmtoken}",
                                      "device_id":"z0f33s43p4",
                                      "device_name":Platform.isAndroid?"android":"iphone",
                                      "ip_address":"192.168.1.1",
                                      "mac_address":"192.168.1.1",
                                      "appName":"superApp",
                                    }
                                  };
                                  fcmtoken = token;
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
                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                        latitude: latitude,
                                        longitude: longitude,
                                        myLocation: myLocation,
                                      )), (route) => false);
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
                                      isLoading =true;
                                      islogin = false;
                                      iswebview = false;
                                    });
                                  });
                                });
                              }
                            }

                            else{
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
                                ).
                                then((value) {
                                  var responsebody = jsonDecode(value.body);
                                  Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                  Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                  Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                  Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                  Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                  setState((){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
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
                                    isLoading = true;
                                    islogin = true;
                                    iswebview = false;
                                  });
                                });
                              });
                            }

                          }).catchError((e){
                            print(e.toString());
                          });
                          setState(()  {


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
                      onTap: ()async{
                        isLoading = false;
                        await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                          print('sign in successfully');
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
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
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
                                    isLoading =true;
                                    islogin = false;
                                    iswebview = false;
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
                              ).then((value){

                                var responsebody = jsonDecode(value.body);

                                Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);

                                setState(() {
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                    latitude: latitude,
                                    longitude: longitude,
                                    myLocation: myLocation,
                                  )), (route) => false);
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
                                  isLoading =true;
                                  islogin = false;
                                  iswebview = false;
                                });
                              });
                            });
                          }

                        });

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color:code!=null?AppColor:Colors.grey[300]
                          ),
                          child: Center(
                              child: isLoading ? Text(isupdate==false?'تاكيد':'تعديل',
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
                                "https://wa.me/+212619157091?text= مشكلتي : لم يصلني كود"),
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
                          'Vérification',
                          style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    height(6),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Veuillez attendre un moment, puis saisissez le code que nous vous avons envoyé sur votre numéro', style: TextStyle(fontSize: 17.0,color: Colors.grey[500]),textAlign: TextAlign.center),
                    ),
                    TextButton(onPressed: (){
                      iswebview = false;
                      setState(() {

                      });
                    }, child: Text('Changer de numéro',
                      style: TextStyle(
                          color: AppColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.8
                      ),)),
                    VerificationCode(
                      fillColor: Colors.grey[100],
                      fullBorder:true,
                      underlineUnfocusedColor: Colors.grey[100],
                      textStyle: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      underlineColor: AppColor,
                      length: 6,
                      cursorColor: AppColor,
                      margin: const EdgeInsets.all(5),
                      onCompleted: (String value)async{
                        code = value;
                        isLoading = false;
                        await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                          if(islogin){
                            if(FirebaseAuth.instance.currentUser!=null){
                              fbm.getToken().then((token)async{
                                var JsonData = {
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
                                fcmtoken = token;
                                await http.post(
                                    Uri.parse('https://www.api.canariapp.com/v1/client/login'),
                                    headers:{'Content-Type':'application/json','Accept':'application/json',},
                                    body:jsonEncode(JsonData)
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
                                    if(widget.routing=='homepage'){
                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                        latitude: latitude,
                                        longitude: longitude,
                                        myLocation: myLocation,
                                      )), (route) => false);
                                    }
                                    if(widget.routing=='homelayout'){
                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                        latitude: latitude,
                                        longitude: longitude,
                                        myLocation: myLocation,
                                      )), (route) => false);
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
                                    isLoading =true;
                                    islogin = false;
                                    iswebview = false;
                                  });
                                });
                              });
                            }
                          }

                          else{
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
                                  if(widget.routing=='homepage'){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
                                  }
                                  if(widget.routing=='homelayout'){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
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
                                  isLoading = true;
                                  islogin = true;
                                  iswebview = false;
                                });
                              });
                            });
                          }

                        }).catchError((e){
                          print(e.toString());
                        });
                        setState(()  {

                        });
                      },
                      onEditing: (bool value) {
                        setState(() {
                          onEditing = value;
                        });
                        if (!onEditing) FocusScope.of(context).unfocus();
                      },
                    ),


                    height(10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Vous avez pas reçu de code ?'),
                        TextButton(onPressed: (){
                          verifyPhoneNumber(context);
                        }, child: Text('Renvoyer',style: TextStyle(
                            color: AppColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.8
                        ),)),
                      ],
                    ),

                    height(6),
                    GestureDetector(
                      onTap: ()async{
                        isLoading = false;
                        await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)).then((value){
                          print('sign in successfully');
                          if(islogin){
                            if(FirebaseAuth.instance.currentUser!=null){
                              fbm.getToken().then((token)async{
                                fcmtoken = token;
                                var JsonData = {
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
                                    body:jsonEncode(JsonData)
                                ).then((value) {
                                  var responsebody = jsonDecode(value.body);

                                  printFullText(responsebody.toString());
                                  Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                  Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                  Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                  Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                  Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                  setState(() {
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
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
                                    isLoading =true;
                                    islogin = false;
                                    iswebview = false;
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
                              ).then((value){
                                var responsebody = jsonDecode(value.body);

                                Cachehelper.sharedPreferences.setString("deviceId",responsebody['device_id'].toString());
                                Cachehelper.sharedPreferences.setString("token",responsebody['token']);
                                Cachehelper.sharedPreferences.setString("first_name",responsebody['client']['first_name']);
                                Cachehelper.sharedPreferences.setString("last_name",responsebody['client']['last_name']);
                                Cachehelper.sharedPreferences.setString("phone",responsebody['client']['phone']);
                                setState(() {
                                  if(widget.routing=='homepage'){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
                                  }
                                  if(widget.routing=='homelayout'){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                      latitude: latitude,
                                      longitude: longitude,
                                      myLocation: myLocation,
                                    )), (route) => false);
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
                                  isLoading =true;
                                  islogin = false;
                                  iswebview = false;
                                });
                              });
                            });
                          }

                        });

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color:code!=null?AppColor:Colors.grey[300]
                          ),
                          child: Center(
                              child: isLoading ? Text(isupdate==false?'Confirmer':'Modifier',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Si vous rencontrez des problèmes lors de inscription',textAlign:TextAlign.center,),
                        TextButton(
                            onPressed: () async => await launch(
                                "https://wa.me/+212619157091?text= مشكلتي : لم يصلني كود"),
                            child: Text('Contactez nous',style: TextStyle(
                                color: AppColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.8
                            ))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
