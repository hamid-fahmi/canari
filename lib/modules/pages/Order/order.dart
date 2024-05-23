import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/modules/pages/Order/paymentPage.dart';
import 'package:shopapp/modules/pages/Static/support_service.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Layout/HomeLayout/home.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import '../../../Layout/HomeLayout/layoutScreen.dart';
import '../../../LayoutMarket/MarketPages/layout_market.dart';
import '../../../shared/network/remote/cachehelper.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Order extends StatefulWidget {
  final Map order;
  final String route;

  Order({Key key, this.order, this.route}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  bool isCancel = true;
  Future cancelOrder()async{
    await http.put(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders/cancel/${widget.order['data']['order_ref']}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      setState(() {
        widget.order['data']["confirmation_status"] = 'cancelled';
        print(responsebody);
        Navigator.pop(context);
      });
    }).catchError((error){
      printFullText(error.toString());
    });
  }
 bool isPaymentChange = true;
  Future changePayment({payload})async{
    setState(() {
      isPaymentChange = false;
    });
    await http.put(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders/${widget.order['data']['order_ref']}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
        body:jsonEncode(payload)
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      setState(() {
        isPaymentChange = true;
        widget.order['data']['payment_method'] = "CASH";
        print(responsebody);
        Navigator.pop(context);
      });
    }).catchError((error){
      printFullText(error.toString());
    });
  }
  bool isLoading = true;
  void _showBottomSheet(BuildContext context) {
      showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, Setstate) {
              return Column(
                mainAxisSize:mainAxisSize,
                children: [
                  isNext
                      ? isDrivedRate == true &&
                      isRestaurantRate == true
                      ? Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close)),
                          TextButton(
                              onPressed: () {
                                Setstate(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 450,
                            width: 370,
                            color: Colors.transparent,
                            child: Container(
                              height: 450,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment:AlignmentDirectional.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 25,right:15,bottom: 20,top: 55),
                                      child: Container(
                                        height: 400,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[300],
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                              offset: Offset(1,2),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top:50),
                                          child: Column(
                                            children: [
                                              height(30),
                                              Text(
                                                'خدمة عملاء',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              height(30),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 25, right: 25),
                                                child: Text(
                                                  'شكرا لمشاركتنا رايك ونحن سعداء بتقديم لك دائما افضل ',
                                                  style: TextStyle(
                                                      height: 1.7,
                                                      fontSize: 16,
                                                      color: Colors.grey[500],
                                                      fontWeight: FontWeight.normal),
                                                  textAlign:
                                                  TextAlign.center,
                                                ),
                                              ),
                                              height(50),
                                              StatefulBuilder(builder: (context,SetState){
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 35, right: 35, top: 15),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      SetState(() {
                                                        isLoading = false;
                                                      });
                                                      await http.post(
                                                          Uri.parse('https://api.canariapp.com/v1/client/reviews'),
                                                          headers: {
                                                            'Content-Type': 'application/json',
                                                            'Accept': 'application/json',
                                                            'Authorization': 'Bearer ${access_token}'
                                                          },
                                                          body: jsonEncode({
                                                            "order_ref":"${widget.order['data']['order_ref']}",
                                                            "reviews":[
                                                              {
                                                                "rate":isLiked?5:3,
                                                                "description":isLiked?"super":"bad",
                                                                "reviewedable":"driver"
                                                              },
                                                              {
                                                                "rate":isRestaurantRateLiked?5:3,
                                                                "description":isRestaurantRateLiked?"super":"bad",
                                                                "reviewedable":"store"
                                                              },
                                                            ]
                                                          })).then((value){
                                                        SetState(() {
                                                          isLoading = true;
                                                          Navigator.of(context).pop();

                                                        });
                                                        print(value.body);
                                                      });
                                                      SetState(() {
                                                        print(isunLiked);
                                                        print(isLiked);
                                                        print(isRestaurantRateLiked);
                                                        print(isRestaurantRateunLiked);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 55,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                                      child: Center(
                                                        child:isLoading?Text(
                                                          'متابعة',
                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                        ):CircularProgressIndicator(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                    AlignmentDirectional.topCenter,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(50.0),
                                            child: Image.asset(
                                                'assets/logo.jpg',
                                                fit: BoxFit.cover))),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                      : Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {

                              },
                              icon: Icon(Icons.close)),
                          TextButton(
                              onPressed: () {
                                Setstate(() {
                                  print(isRestaurantRate);
                                });
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )),
                        ],
                      ),
                      isDrivedRate
                          ? Column(
                        children: [
                          Container(
                            height: 450,
                            width: 370,
                            color: Colors.transparent,
                            child: Container(
                              height: 450,
                              child: Stack(
                                children: [
                                  Align(alignment:AlignmentDirectional.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 25,right: 15,bottom: 20,top:55),
                                      child:Container(
                                        height: 400,
                                        decoration:BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[300],
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                              offset: Offset(1, 2),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        width: double.infinity,
                                        child: Padding(padding: const EdgeInsets.only(top: 50),
                                          child: Column(
                                            children: [
                                              height(30),
                                              Text(
                                                'كيف كانت خدمة المطعم ؟',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              height(30),
                                              Padding(padding: const EdgeInsets.only(left: 25, right: 25),
                                                child: Text(
                                                  'ستساعد ملاحظاتك في تحسين تجربة التسليم',
                                                  style: TextStyle(height: 1.7, fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.normal),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              height(30),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      Setstate(() {
                                                        isRestaurantRateunLiked = true;
                                                        isRestaurantRate = true;
                                                        isRestaurantRateLiked = false;
                                                        print(isRestaurantRateunLiked);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300], width: 1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: FaIcon(
                                                          isRestaurantRateunLiked ? FontAwesomeIcons.solidThumbsDown : FontAwesomeIcons.thumbsDown,
                                                          color: Colors.blue,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  width(10),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Setstate(() {
                                                        isRestaurantRateLiked = true;
                                                        isRestaurantRateunLiked = false;
                                                        isRestaurantRate = true;
                                                        print(isRestaurantRateLiked);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300], width: 1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: FaIcon(
                                                          isRestaurantRateLiked ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                                                          color: Colors.blue,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child:ClipRRect(
                                          borderRadius: BorderRadius.circular(50.0),
                                          child:Image.network('https://api.canariapp.com/media/301/LA-FAVORITA-(2).png',
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ) : Column(
                        children: [
                          Container(
                            height: 450,
                            width: 370,
                            color: Colors.transparent,
                            child: Container(
                              height: 450,
                              child: Stack(
                                children: [
                                  Align(alignment: AlignmentDirectional.bottomCenter,
                                    child: Padding(padding: const EdgeInsets.only(left: 25, right:15,bottom:20, top: 55),
                                      child:Container(
                                        height:400,
                                        decoration:BoxDecoration(
                                          color:Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[300],
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                              offset: Offset(1, 2),
                                            ),
                                          ],
                                          borderRadius:BorderRadius.circular(7),
                                        ),
                                        width: double.infinity,
                                        child:Padding(padding:const EdgeInsets.only(top: 50),
                                          child:Column(
                                            children: [
                                              height(30),
                                              Text(
                                                'كيف كانت خدمة التوصيل ؟',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              height(30),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 25, right: 25),
                                                child: Text(
                                                  'ستساعد ملاحظاتك في تحسين تجربة التسليم',
                                                  style: TextStyle(height: 1.7, fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.normal),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              height(30),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      Setstate(() {
                                                        isunLiked = true;
                                                        isDrivedRate = true;
                                                        print(isunLiked);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300], width: 1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: FaIcon(
                                                          isunLiked ? FontAwesomeIcons.solidThumbsDown : FontAwesomeIcons.thumbsDown,
                                                          color: Colors.blue,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  width(10),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Setstate(() {
                                                        isLiked = true;
                                                        isDrivedRate = true;
                                                        print(isLiked);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300], width: 1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: FaIcon(
                                                          isLiked ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                                                          color: Colors.blue,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:AlignmentDirectional.topCenter,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          shape:BoxShape.circle,
                                          color:Colors.blue,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:BorderRadius.circular(50.0),
                                          child: Image.asset(
                                              'assets/rider.png',
                                              fit: BoxFit.cover),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                      : Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(padding:const EdgeInsets.only(right: 50, top: 5),
                              child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    shape:BoxShape.circle,
                                    image:DecorationImage(
                                        image: AssetImage('assets/rider.png'),
                                        fit: BoxFit.cover)),
                              )),
                          Padding(padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    shape:BoxShape.circle,
                                    image: DecorationImage(image: NetworkImage('https://api.canariapp.com/media/301/LA-FAVORITA-(2).png'))),
                              )),
                        ],
                      ),
                      height(15),
                      Text('قيم الخدمتنا رأيك يهمنا'),
                      height(10),
                      Padding(padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          'أخبرنا عن جودة الطعام المطعم والخدمة التوصيل لي تساعدنا على تحسين من الخدمة',
                          style: TextStyle(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      height(20),
                      Padding(
                        padding: const EdgeInsets.only(left: 35, right: 35, top: 15),
                        child: GestureDetector(
                          onTap: () {
                            Setstate(() {
                              isNext = true;
                            });
                          },
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:BorderRadius.circular(5)),
                            child: Center(
                              child: Text(
                                'استمر',
                                style: TextStyle(
                                    color:Colors.white,
                                    fontWeight:FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      height(10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 55,
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'ليس الآن',
                              style: TextStyle(
                                  color: AppColor,
                                  fontWeight:FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      height(15)
                    ],
                  )
                ],
              );
            },
          );
      },
    );
  }




  void _showAlert(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:true,
      isDismissible:false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context,Setstate){
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: (){
                        Setstate((){
                          isCancel = false;
                        });
                        cancelOrder();
                      },
                      child:isCancel?Text(lg==''?'الغاء الطلب':"Annulé la commande ",style: TextStyle(
                          color:Colors.grey[600],
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400
                      ),):CircularProgressIndicator(color:AppColor,),
                    ),
                  ),
                ),
                height(10),
                Image.asset('assets/paymentFaild.png',height:90,width:90,color:AppColor),
                height(10),
                Text(lg=='ar'?'عملية الدفع فشلت':"Paiement échoué",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                height(10),
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: Text(lg==''?'أُووبس! يبدو أن هناك مشكلة في دفعتك! يرجى تواصل معنا من اجل لمزيد من المعلومات':"Oups ! Il semble y avoir un problème avec votre paiement ! Veuillez nous contacter pour plus d'informations",style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w500,height: 1.5),textAlign: TextAlign.center),
                ),
                height(20),
                Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   children: [
                     widget.order['data']['store']['payment_methods'].contains('CASH')?Padding(
                       padding: const EdgeInsets.only(left: 15,right: 15),
                       child: Container(
                         height: 50,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(8),
                             color:AppColor,
                             boxShadow: [
                               BoxShadow(
                                   color: Colors.grey[300],
                                   blurRadius: 2,
                                   spreadRadius: 1,
                                   offset: Offset(1,2))
                             ]
                         ),
                         width: double.infinity,
                         child:isPaymentChange?TextButton(
                           onPressed: (){
                             Setstate((){
                               isPaymentChange = false;
                             });
                             changePayment(
                               payload: {
                                 "payment_method":"CASH",
                               }
                             );
                           },
                           child:Text(lg=='ar'?'دفع نقدا':"Payer en cash",style: TextStyle(
                               color: Colors.white,
                               fontWeight: FontWeight.w500
                           )),
                         ):Center(child:CircularProgressIndicator(color: Colors.white,)),
                       ),
                     ):height(0),
                     height(10),
                     Padding(
                       padding: const EdgeInsets.only(left: 15,right: 15),
                       child: Container(
                         height: 50,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(
                               width: 1,
                               color: Colors.grey[400],
                             )
                         ),
                         width: double.infinity,
                         child: TextButton(
                           onPressed: () {
                             navigateTo(context, PaymentPage(refCode:int.parse(widget.order['data']['order_ref'])));
                           },
                           child: Text(lg==''?'اعادة محاولة':"essayer à nouveau",style: TextStyle(
                               color: Colors.black,
                               fontWeight: FontWeight.w500
                           )),
                         ),
                       ),
                     ),
                     height(10),
                     Padding(
                       padding: const EdgeInsets.only(left: 15,right: 15),
                       child: Container(
                         height: 50,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(5),
                         ),
                         width: double.infinity,
                         child: TextButton(
                           onPressed: (){
                             navigateTo(context, SupportService());
                           },
                           child: Text(lg=='ar'? 'تواصل معنا':"Contactez nous",style: TextStyle(
                               color: Colors.black,
                               fontWeight: FontWeight.bold
                           )),
                         ),
                       ),
                     ),

                   ],
                 ),
               )

              ],
            );
          },


        );


      },
    );
  }

  String access_token = Cachehelper.getData(key: "token");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isNext = false;
  bool isLiked = false;
  bool isunLiked = false;

  bool isDrivedRate = false;
  bool isRestaurantRate = false;

  bool isRestaurantRateLiked = false;
  bool isRestaurantRateunLiked = false;

  MainAxisSize mainAxisSize = MainAxisSize.min;
  @override
  void initState() {
    Future.delayed(Duration(seconds:1),(){
      if(widget.order['data']["delivery_status"] != "delivered" && msg != 'تم إلغاء طلبيتك'){

        if(widget.order['data']['payment_method']=='CARD' && widget.order['data']['payment_status'] == 'unpaid' ||  widget.order['data']['payment_status'] == 'semi_paid')
          _showAlert(context);
      }

      if(widget.order['data']["delivery_status"] == "delivered" && widget.order['data']['reviews'].length==0){
        _showBottomSheet(context);
      }else{
        print('revied');
      }
    });
    FirebaseMessaging.instance.getInitialMessage();
    super.initState();
  }
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  String MyLocation = Cachehelper.getData(key: "myLocation");
  String img = 'assets/canari-play.jpg';
  String msg = "تم الطلب!  جاري موافقة عليه";
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
      if (int.tryParse(widget.order['data']['order_ref']) ==
          int.tryParse(jsonMap['order_ref'])) {
        if (jsonMap["fulfillment_status"] == "accepted") {
          setState(() {
            widget.order['data']['prospective_fulfillment_time'] =
                jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] =
                jsonMap['prospective_delivery_time'];
            msg = 'المطعم يحضر طلبك';
            img = "assets/canari-cook.jpg";
            activeIndex = 1;
          });
        }

        if (jsonMap["fulfillment_status"] == "ready") {
          setState(() {
            jsonMap['prospective_fulfillment_time'] =
                widget.order['data']['prospective_fulfillment_time'];
            jsonMap['prospective_delivery_time'] =
                widget.order['data']['prospective_delivery_time'];
            msg = 'طلبك جاهز للاستلام الآن';
            img = "assets/canari-cook.jpg";
            activeIndex = 1;
          });
        }

        if (jsonMap["delivery_status"] == "pickup") {
          if (jsonMap['driver'] != null) {
            setState(() {
              widget.order['data']['driver'] = jsonMap['driver'];
            });
          }
          setState(() {
            widget.order['data']['prospective_fulfillment_time'] =
                jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] =
                jsonMap['prospective_delivery_time'];
            msg = 'جاري توصيل طلبك';
            img = 'assets/delivery_guy.gif';
            activeIndex = 2;
          });
        }

        if (jsonMap["delivery_status"] == "delivered") {
          setState(() {
            widget.order['data']['prospective_fulfillment_time'] =
                jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] =
                jsonMap['prospective_delivery_time'];
            widget.order['data']["delivery_status"] =
                jsonMap['delivery_status'];
            msg = 'تم توصيل طلبيتك';
            img = 'assets/sucsses.gif';
            activeIndex = 3;
          });
        }

        if (jsonMap["delivery_status"] == "returned") {
          setState(() {
            widget.order['data']['prospective_fulfillment_time'] =
                jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] =
                jsonMap['prospective_delivery_time'];
            msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
            img = 'assets/cross.png';
          });
        }

        if (jsonMap["confirmation_status"] == "cancelled") {

          setState(() {
            widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
            msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
            img = 'assets/cross.png';
          });
        }

        if (jsonMap["fulfillment_status"] == "non-accepted") {
          setState(() {
            widget.order['data']['prospective_fulfillment_time'] =
                jsonMap['prospective_fulfillment_time'];
            widget.order['data']['prospective_delivery_time'] =
                jsonMap['prospective_delivery_time'];
            msg = 'تم إلغاء طلبيتك';
            img = 'assets/cross.png';
          });
        }
      }
    });
    if (widget.order['data']["fulfillment_status"] == "accepted") {
      setState(() {
        msg = 'المطعم يحضر طلبك';
        img = "assets/canari-cook.jpg";
        activeIndex = 1;
      });
    }

    if (widget.order['data']["fulfillment_status"] == "ready") {
      setState(() {
        msg = 'طلبك جاهز للاستلام الآن';
        img = "assets/canari-cook.jpg";
        activeIndex = 1;
      });
    }

    if (widget.order['data']["delivery_status"] == "pickup") {
      setState(() {
        msg = 'جاري توصيل طلبك';
        img = 'assets/delivery_guy.gif';
        activeIndex = 2;
      });
    }

    if (widget.order['data']["delivery_status"] == "delivered") {
      setState(() {
        msg = 'تم توصيل طلبيتك';
        img = 'assets/sucsses.gif';
        activeIndex = 3;
      });
    }

    if (widget.order['data']["delivery_status"] == "returned") {
      setState(() {
        widget.order['data']["delivery_status"] = "cancelled";
        msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
        img = 'assets/cancel.png';
      });
    }

    if (widget.order['data']["confirmation_status"] == "cancelled") {

      setState(() {
        widget.order['data']["delivery_status"] = "cancelled";
        msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
        img = 'assets/cross.png';
      });
    }

    if (widget.order['data']["fulfillment_status"] == "non-accepted") {
      setState(() {
        widget.order['data']["delivery_status"] = "cancelled";
        msg = 'تم إلغاء طلبيتك';
        img = 'assets/cross.png';
      });
    }

Future<void>firebaseMessagingBackgroundHandler(RemoteMessage message,)async{
  if (message.data!=null) {
     Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
     printFullText('notification :${jsonMap.toString()}');

    if(int.tryParse(widget.order['data']['order_ref'])==int.tryParse(jsonMap['order_ref'])){
      if(jsonMap['driver']!=null){
        setState(() {
          widget.order['data']['driver'] = jsonMap['driver'];
        });
      }

      if(jsonMap["fulfillment_status"] == "accepted"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          msg = 'المطعم يحضر طلبك';
          img = "assets/canari-cook.jpg";
        });
      }

      if(jsonMap["fulfillment_status"] == "ready"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          msg = 'طلبك جاهز للاستلام الآن';
          img = "assets/canari-cook.jpg";
        });
      }

      if(jsonMap["delivery_status"] == "pickup"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          msg = 'جاري توصيل طلبك';
          img = 'assets/delivery_guy.gif';
        });
      }

      if(jsonMap["delivery_status"] == "delivered"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          widget.order['data']["delivery_status"] = jsonMap['delivery_status'];
          msg = 'تم توصيل طلبيتك';
          img = 'assets/sucsses.gif';

        });

      }

      if(jsonMap["delivery_status"] == "returned"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          widget.order['data']["delivery_status"] = jsonMap['delivery_status'];
          msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
          img = 'assets/cross.png';

        });

      }

      if(jsonMap["confirmation_status"] == "cancelled"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          widget.order['data']["delivery_status"] = jsonMap['delivery_status'];
          msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
          img = 'assets/cross.png';

        });

      }

      if(jsonMap["fulfillment_status"] == "non-accepted"){
        setState(() {
          widget.order['data']['prospective_fulfillment_time'] = jsonMap['prospective_fulfillment_time'];
          widget.order['data']['prospective_delivery_time'] = jsonMap['prospective_delivery_time'];
          widget.order['data']["delivery_status"] = jsonMap['delivery_status'];
          msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
          img = 'assets/cross.png';

        });

      }

    }






  }}

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data != null) {
        Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
        if (int.tryParse(widget.order['data']['order_ref']) ==
            int.tryParse(jsonMap['order_ref'])) {
          if (jsonMap["fulfillment_status"] == "accepted") {
            setState(() {
              widget.order['data']['prospective_fulfillment_time'] =
                  jsonMap['prospective_fulfillment_time'];
              widget.order['data']['prospective_delivery_time'] =
                  jsonMap['prospective_delivery_time'];
              msg = 'المطعم يحضر طلبك';
              img = "assets/canari-cook.jpg";
              activeIndex = 1;
            });
          }

          if (jsonMap["fulfillment_status"] == "ready") {
            setState(() {
              widget.order['data']['prospective_fulfillment_time'] =
                  jsonMap['prospective_fulfillment_time'];
              widget.order['data']['prospective_delivery_time'] =
                  jsonMap['prospective_delivery_time'];
              msg = 'طلبك جاهز للاستلام الآن';
              img = "assets/canari-cook.jpg";
              activeIndex = 1;
            });
          }

          if (jsonMap["delivery_status"] == "pickup") {
            if (jsonMap['driver'] != null) {
              setState(() {
                widget.order['data']['driver'] = jsonMap['driver'];
              });
            }
            setState(() {
              widget.order['data']['prospective_fulfillment_time'] =
                  jsonMap['prospective_fulfillment_time'];
              widget.order['data']['prospective_delivery_time'] =
                  jsonMap['prospective_delivery_time'];
              msg = 'جاري توصيل طلبك';
              img = 'assets/delivery_guy.gif';
              activeIndex = 2;
            });
          }

          if (jsonMap["delivery_status"] == "delivered") {
            setState(() {
              widget.order['data']['prospective_fulfillment_time'] =
                  jsonMap['prospective_fulfillment_time'];
              widget.order['data']['prospective_delivery_time'] =
                  jsonMap['prospective_delivery_time'];
              widget.order['data']["delivery_status"] =
                  jsonMap['delivery_status'];
              msg = 'تم توصيل طلبيتك';
              img = 'assets/sucsses.gif';
              activeIndex = 3;
            });
          }

          if (jsonMap["delivery_status"] == "returned") {
            setState(() {
              widget.order['data']["delivery_status"] =
                  jsonMap['delivery_status'];
              msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
              img = 'assets/cross.png';
            });
          }

          if (jsonMap["confirmation_status"] == "cancelled") {
            setState(() {
              msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
              img = 'assets/cross.png';
            });
          }

          if (jsonMap["fulfillment_status"] == "non-accepted") {
            setState(() {
              msg = lg=="ar"?'تم إلغاء طلبيتك':"Votre commande a été annulée";
              img = 'assets/cross.png';
            });
          }
        }
      }
    });

    return WillPopScope(
      onWillPop: () async {
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Home(
                      latitude: latitud,
                      longitude: longitud,
                      myLocation: MyLocation,
                    )),
            (route) => false);
        return true;
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned.fill(
                bottom: MediaQuery.of(context).size.height * 0.4,
                child:Image.asset(
                  img,
                  fit:(msg=='تم إلغاء طلبيتك'||msg=='Votre commande a été annulée')?BoxFit.cover
                      : BoxFit.cover,
                ),
              ),
              Positioned(
                  left: 15,
                  top: 40,
                  child: CircleAvatar(
                      maxRadius: 20,
                      backgroundColor: Colors.white,
                      child: IconButton(
                          onPressed: (){
                            if(service_type=='grocery'){
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutMarket()), (route) => route.isFirst);
                            }else{
                              if(service_type=='shop'){
                                setState(() {
                                  service_type = 'shop';
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                    category: 'shop',
                                    latitude:latitude ,
                                    longitude:longitude,
                                    myLocation: myLocation,
                                  )), (route) => route.isFirst);
                                });
                              }else{
                                if(service_type=='para_pharmacy'){
                                  print(service_type);
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                    category:service_type,
                                    latitude:latitude ,
                                    longitude:longitude,
                                    myLocation: myLocation,
                                  )), (route) => route.isFirst);
                                }else{
                                  if(service_type=='food'){
                                    print(service_type);
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home(
                                      category:service_type,
                                      latitude:latitude ,
                                      longitude:longitude,
                                      myLocation: myLocation,
                                    )), (route) => route.isFirst);
                                  }else{

                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LayoutScreen(
                                      latitude:latitude ,
                                      longitude:longitude,
                                      myLocation: myLocation,
                                    )), (route) => route.isFirst);
                                  }
                                }
                              }
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          )))),
              Positioned(
                  right: 15,
                  top: 40,
                  child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xff03d603)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                        ),
                          elevation: MaterialStateProperty.all(2)
                      ),

                      onPressed: (){
                        navigateTo(context,SupportService());
                      },child:Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Row(
                        children: [
                         Icon(Icons.support_agent,color:Colors.white,size: 20),
                         width(5),
                         Text(DemoLocalization.of(context).getTranslatedValue('Equipe_de_support'),style: TextStyle(fontSize: 12.5,color:Colors.white,fontWeight: FontWeight.bold),)
                    ],
                  ),
                      ))
              ),
              Positioned(
                  child: DraggableScrollableSheet(
                    initialChildSize: .7,
                    minChildSize: .5,
                    maxChildSize: .9,
                    builder: (BuildContext context,
                    ScrollController scrollController) {
                   return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              offset: Offset(0, 3),
                              spreadRadius: 2,
                              color: Colors.grey[350])
                        ]),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      controller: scrollController,
                      children:[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (msg=='تم إلغاء طلبيتك'||msg=='Votre commande a été annulée')?Padding(
                              padding: const EdgeInsets.only(left: 20,top: 0,right: 20),
                              child: Text(DemoLocalization.of(context).getTranslatedValue('annulée'),style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            ):
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20,top: 0,right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.order['data']["delivery_status"] == "delivered" ?Text(DemoLocalization.of(context).getTranslatedValue('Votre_commande_a_été_livrée'),style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),):height(0),
                                    widget.order['data']["delivery_status"] == "delivered" ?height(0):(msg!='تم إلغاء طلبيتك'||msg!='Votre commande a été annulée')?Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DemoLocalization.of(context).getTranslatedValue('heure'),style: TextStyle(fontSize: 15),),
                                        height(10),
                                        widget.order['data']['prospective_fulfillment_time']!=''?
                                        Directionality(
                                          textDirection: ui.TextDirection.ltr,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('${DateFormat('HH:mm').format(DateTime.parse(widget.order['data']['prospective_fulfillment_time']))} PM  -',
                                                  style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
                                              width(5),
                                              Text('${DateFormat('HH:mm').format(DateTime.parse(widget.order['data']['prospective_delivery_time']))} PM ',
                                                  style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ): Text('',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                                      ],
                                    ):height(0),
                                  ],
                                ),
                              ),
                            ),
                            height(20),
                            (msg=='تم إلغاء طلبيتك'||msg=='Votre commande a été annulée')? devider():
                            Column(
                              children: [
                                AnotherStepper(
                                  stepperList: [
                                    Stepper(
                                        title: DemoLocalization.of(context).getTranslatedValue('confirmation_on_process'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        icon:Icons.fastfood,
                                        containerColor: AppColor
                                    ),
                                    activeIndex>=1?
                                    Stepper(
                                        title: DemoLocalization.of(context).getTranslatedValue('on_process'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        icon:FontAwesomeIcons.bowlFood,
                                        containerColor: AppColor
                                    ):
                                    Stepper(
                                      title: DemoLocalization.of(context).getTranslatedValue('on_process'),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      icon:FontAwesomeIcons.bowlFood,
                                      containerColor:Colors.grey.shade300,
                                    ),
                                    activeIndex>=2?
                                    Stepper(
                                        title: DemoLocalization.of(context).getTranslatedValue('delivery_process'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        icon:Icons.delivery_dining,
                                        containerColor: AppColor
                                    ):
                                    Stepper(
                                        title: DemoLocalization.of(context).getTranslatedValue('delivery_process'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        icon:Icons.delivery_dining,
                                        containerColor: Colors.grey.shade300
                                    ),
                                    activeIndex>=3?
                                    Stepper(
                                        title: DemoLocalization.of(context).getTranslatedValue('delivered'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        icon:Icons.check,
                                        containerColor: AppColor
                                    ):
                                    Stepper(
                                        title:DemoLocalization.of(context).getTranslatedValue('delivered'),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        icon:Icons.check,
                                        containerColor: Colors.grey.shade300
                                    ),
                                  ],
                                  stepperDirection: Axis.horizontal,
                                  iconWidth: 40,
                                  iconHeight: 40,
                                  activeBarColor: ui.Color(0xFFfb133a),
                                  inActiveBarColor: Colors.grey.shade300,
                                  inverted: true,
                                  verticalGap: 40,
                                  activeIndex: activeIndex,
                                  barThickness: 6,
                                ),

                                height(20),
                                widget.order['data']['driver']==null? devider():height(0),
                                widget.order['data']['driver']!=null? devider():height(0),
                                widget.order['data']['driver']==null ? height(0):widget.order['data']["delivery_status"] != "delivered"?
                                Container(
                                  height: 150,
                                  width: double.infinity,

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap:(){
                                          launch("tel://${widget.order['data']['driver']['phone']}");
                                          },
                                        child: Container(
                                          height: 100,
                                          width: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15,right: 15),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('${widget.order['data']['driver']['name']}',style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 19
                                                    ),),
                                                    height(3),
                                                    Text(DemoLocalization.of(context).getTranslatedValue('hero_for_today'),style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 13,
                                                        color: Color(0xff302f2f)
                                                    ),),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  height: 50,
                                                  width: 50,
                                                  child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(6),
                                                      child: Image.asset("assets/helmet.png",)
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 0.5,
                                        width: double.infinity,
                                        color: Colors.black38,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15,right: 15,top: 11),
                                        child: GestureDetector(
                                          onTap: (){
                                            launch("tel://${widget.order['data']['driver']['phone']}");
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap:(){
                                                  launch("tel://${widget.order['data']['driver']['phone']}");
                                                },
                                                child: Text(DemoLocalization.of(context).getTranslatedValue('Contactez_les'),style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                              Icon(Icons.arrow_forward_ios_rounded)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ):height(0),
                                widget.order['data']['driver'] !=null? widget.order['data']["delivery_status"] != "delivered"? devider():height(0):height(0),
                                widget.order['data']['driver'] !=null?widget.order['data']["delivery_status"] != "delivered"?height(30):height(20):height(0),

                              ],
                            ),
                            // (msg=='تم إلغاء طلبيتك'||msg=='Votre commande a été annulée')?height(0):devider(),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:EdgeInsets.only(left: 20,right: 20,top:widget.order['data']['driver'] !=null? 0:20),
                                    child:Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black87,fontSize: 16)),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on,color: AppColor,size: 32,),
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(child:Text(
                                                      widget.order['data']['delivery_address']['label']!=null?"${widget.order['data']['delivery_address']['label']}":'موقعي',
                                                      textAlign: TextAlign.start,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15),
                                                    ),),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                  ],
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 2,
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            height(20),
                            devider(),
                            height(30),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Text(DemoLocalization.of(context).getTranslatedValue('Votre_commande_de'),style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black87,fontSize: 17)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${widget.order['data']['store']['name']}',style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold)),
                                              ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Image.network("${widget.order['data']['store']['logo']}",height: 55,)),
                                            ],
                                          ),
                                        ),
                                        height(15),
                                        ListView.separated(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context,index){
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 20,),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5,right: 5),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 2),
                                                            child: Text('x${widget.order['data']['products'][index]['quantity']}',style:TextStyle(fontSize: 13.5,fontWeight: FontWeight.bold,color: AppColor),),
                                                          ),
                                                          width(10),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text('${widget.order['data']['products'][index]['name']}',style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.bold),),
                                                                Text(
                                                                  '',
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      fontSize: 12.5,
                                                                      color: Color.fromARGB(255, 78, 78, 78), fontWeight: FontWeight.normal),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          width(15),
                                                          Text('${widget.order['data']['products'][index]['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 13.5,fontWeight: FontWeight.bold),),
                                                          if(widget.order['data']['products'][index]['price']!=widget.order['data']['products'][index]['original_price'])
                                                            width(5),
                                                          if(widget.order['data']['products'][index]['price']!=widget.order['data']['products'][index]['original_price'])
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 2),
                                                              child: Text('${widget.order['data']['products'][index]['original_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',
                                                                style: TextStyle(fontSize: 12.5,fontWeight: FontWeight.bold,
                                                                    decoration: TextDecoration.lineThrough,
                                                                    color: Colors.grey[400]
                                                                ),),
                                                            ),

                                                        ],
                                                      ),
                                                    ),
                                                    height(5),
                                                    ListView.builder(
                                                      physics: NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemBuilder:(context,atributindex){
                                                        return Padding(
                                                          padding: const EdgeInsets.only(bottom: 5,top: 5),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 35),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text('${widget.order['data']['products'][index]['attributes'][atributindex]['name']}')
                                                                      ],
                                                                    ),
                                                                    widget.order['data']['products'][index]['attributes'][atributindex]['price']!=0? Text('${widget.order['data']['products'][index]['attributes'][atributindex]['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 13.5,fontWeight: FontWeight.normal),):height(0),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      itemCount: widget.order['data']['products'][index]['attributes'].length,)
                                                  ],
                                                ),
                                              );
                                            }, separatorBuilder: (context,index){
                                          return SizedBox(height: 5,);
                                        }, itemCount:widget.order['data']['products'].length)
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            height(20),
                            devider(),
                            height(30),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child:Text(DemoLocalization.of(context).getTranslatedValue('Details_de_paiement'),style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500)),
                                  ),
                                  height(10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DemoLocalization.of(context).getTranslatedValue('Mode_de_paiement')),
                                        width(5),
                                        Text(widget.order['data']['payment_method']=='CASH'?DemoLocalization.of(context).getTranslatedValue('Payer_en_cash'):DemoLocalization.of(context).getTranslatedValue('Payer_par_carte'),style: TextStyle(fontSize: 14.5,fontWeight: FontWeight.w400),)
                                      ],
                                    ),
                                  ),
                                  height(10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DemoLocalization.of(context).getTranslatedValue('Frais_de_livraison')),
                                        width(5),
                                        Text(widget.order['data']['delivery_price']!="0.00"?'${widget.order['data']['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w400),),                                      ],
                                    ),
                                  ),
                                  if(widget.order['data']['weather_fee']!=0)
                                    height(10),
                                  if(widget.order['data']['weather_fee']!=0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: Row(
                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DemoLocalization.of(context).getTranslatedValue('Frais_de_météo'),
                                        ),
                                        Text(
                                            "${widget.order['data']['weather_fee']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                            style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                                  ),
                                  if(widget.order['data']['service_fee']!=0)
                                    height(10),
                                  if(widget.order['data']['service_fee']!=0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20,right: 20),
                                      child: Row(
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DemoLocalization.of(context).getTranslatedValue('Frais_de_service'),
                                          ),
                                          Text(
                                            "${widget.order['data']['service_fee']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                            style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                            height(10),
                            Padding(
                              padding: const EdgeInsets.only(left: 20,right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Total'),style: TextStyle(fontSize: 17,color: Colors.black,fontWeight: FontWeight.bold)),
                                  Text('${widget.order['data']['total'].toStringAsFixed(2)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w400),),
                                ],
                              ),
                            ),
                            height(20),
                            devider(),
                            height(30),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20,right: 20),
                                        child:Text('${DemoLocalization.of(context).getTranslatedValue('Support')}',style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500)),
                                      ),
                                      height(5),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20,right: 20),
                                        child:  Text('${DemoLocalization.of(context).getTranslatedValue('Numero_de_commande')} #${widget.order['data']['order_ref']}'),
                                      ),
                                      height(5),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: CircleAvatar(
                                      child: TextButton(
                                        onPressed: () async => await launch(
                                            "https://wa.me/+212619157091?text=${DemoLocalization.of(context).getTranslatedValue('Numero_de_commande')} : *${widget.order['data']['order_ref']}* : "),
                                        child:Icon(FontAwesomeIcons.whatsapp,size: 33,color: Color(0xff25D366)),
                                      ),
                                      backgroundColor: Colors.grey[50],
                                      maxRadius: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            height(10),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ))
            ],
          )),
    );
  }

  Container devider() {
    return Container(
      height: 8,
      color: Colors.grey[100],
      width: double.infinity,
    );
  }

  StepperData Stepper(
      {String title,
      Color color,
      Color containerColor,
      FontWeight fontWeight,
      IconData icon}) {
    return StepperData(
        title: StepperText(
          title,
          textStyle:
              TextStyle(color: color, fontSize: 10, fontWeight: fontWeight),
        ),
        iconWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Icon(icon, color: Colors.white),
        ));
  }
}

void _showBottomSheet() {}
