import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopapp/Layout/HomeLayout/home.dart';
import 'package:shopapp/modules/pages/Order/paymentPage.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:http/http.dart' as http;

import '../../../Layout/shopcubit/storecubit.dart';
import '../../../Layout/shopcubit/storestate.dart';
import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';
import 'order.dart';


class AnimatedListView extends StatefulWidget {
  final String routing;
  final List order;
  final myLocation;
  final total;
  final deliveryPrice;
  final note;
  final coupon;
  final CouponController;
  final payload;
  final method_payment;
  final TextEditingController emailController;
  const AnimatedListView({Key key, this.order,this.myLocation,this.total,this.deliveryPrice,this.note,this.payload, this.routing, this.coupon, this.method_payment, this.emailController, this.CouponController}) : super(key: key);
  @override
  _AnimatedListViewState createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<AnimatedListView> with SingleTickerProviderStateMixin{

  String device_id = Cachehelper.getData(key:"deviceId");
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  String access_token = Cachehelper.getData(key: "token");

  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer timer;
  bool load = false;


  void StartTimer(){
    Future.delayed(Duration(seconds: 3),(){
      start();
    });
  }

  Map<String, dynamic> myorder = {};
  void start(){
    timer = Timer.periodic(Duration(milliseconds:70), (_){
      if(seconds>0){
        seconds--;
        setState(() {
        });
      }else if(seconds==0){
        load = false;
        if(widget.method_payment=="cash"){
          http.post(Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
            body:jsonEncode({
              "store_id":StoreId,
              "payment_method":"CASH",
              "coupon_code":widget.coupon['code'],
              "delivery_address":{
                "label":widget.myLocation,
                "latitude":latitud,
                "longitude":longitud
              },
              "type":'delivery',
              "note":{
                "allergy_info":"${widget.note}",
                "special_requirements":""
              },
              "products":dataService.itemsCart,
              "device_id":device_id
            }),
            headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
          ).then((value) {
            if(widget.method_payment=='cash'){
              var responsebody = jsonDecode(value.body);
              print(responsebody['order_ref']);
              http.get(
                  Uri.parse('https://www.api.canariapp.com/v1/client/orders/${responsebody['order_ref']}?include=products,store'),
                  headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
              ).then((value) {
                var responsebody = jsonDecode(value.body);
                myorder = responsebody;
                print('order:${responsebody}');
                Future.delayed(Duration(milliseconds: 200),(){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Order(order:myorder)));
                });
                dataService.itemsCart.clear();
                setState(() {
                  load = true;
                });

              }).catchError((error){
                printFullText(error.toString());
                setState(() {

                });
              });
              print(value.body);
            }else{
              var responsebody = jsonDecode(value.body);
              dataService.itemsCart.clear();
              setState(() {
                load = true;
              });
              Future.delayed(Duration(milliseconds: 200),(){
                navigateTo(context, PaymentPage(refCode:responsebody['order_ref']));
              });
            }
          });
        }
        else{
          http.put(Uri.parse('https://api.canariapp.com/v1/client/profile'),
            body:jsonEncode({
              "email":"${widget.emailController.text}"
            }),
            headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
          ).then((value) {
            http.post(Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
              body:jsonEncode({
                "store_id":StoreId,
                "payment_method":"CARD",
                "coupon_code":widget.coupon['code'],
                "delivery_address":{
                  "label":widget.myLocation,
                  "latitude":latitud,
                  "longitude":longitud
                },
                "type":'delivery',
                "note":{
                  "allergy_info":"${widget.note}",
                  "special_requirements":""
                },
                "products":dataService.itemsCart,
                "device_id":device_id
              }),
              headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
            ).then((value) {
              if(widget.method_payment=='cash'){
                var responsebody = jsonDecode(value.body);
                print(responsebody['order_ref']);
                http.get(
                    Uri.parse('https://www.api.canariapp.com/v1/client/orders/${responsebody['order_ref']}?include=products,store'),
                    headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
                ).then((value) {
                  var responsebody = jsonDecode(value.body);
                  myorder = responsebody;
                  print('order:${responsebody}');
                  Future.delayed(Duration(milliseconds: 200),(){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Order(order:myorder)));
                  });
                  dataService.itemsCart.clear();
                  setState(() {
                    load = true;
                  });
                }).catchError((error){
                  printFullText(error.toString());
                  setState(() {

                  });
                });
                print(value.body);
              }else{
                var responsebody = jsonDecode(value.body);
                dataService.itemsCart.clear();
                setState(() {
                  load = true;
                });
                Future.delayed(Duration(milliseconds: 200),(){
                  navigateTo(context, PaymentPage(refCode:responsebody['order_ref']));
                });
              }
            });
          }).catchError((onError){

          });
        }

        timer.cancel();

      }
    });
  }

   AnimationController _controller;
   List<Widget> items;
   List<Animation<double>> itemAnimations;

  @override
  void initState() {
    super.initState();

    StartTimer();

    var address = widget.myLocation;

    var restaurant = widget.order[0]['restaurant'];

    var itemName = dataService.itemsCart;

    var orders = [widget.myLocation, restaurant,itemName];

    items = List.generate(orders.length, (index) => Padding(

      padding:EdgeInsets.only(right: 20,top:25,left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          itemName == orders[index]?Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Divider(),
            Container(
             height:dataService.itemsCart.length>=5?300:null,
             color:dataService.itemsCart.length>=5? Color(0xfff8f8f8):Colors.white,
             width:double.infinity,
             child:ListView.builder(
                 shrinkWrap: true,
                 physics: BouncingScrollPhysics(),
                 itemCount:dataService.itemsCart.length,
                 itemBuilder: (context,index){
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Padding(
                         padding: const EdgeInsets.only(left: 5,right: 15,top: 15,bottom: 5),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(top: 2),
                               child: Text('x${dataService.itemsCart[index]['quantity']}',style:TextStyle(fontSize: 13.5,fontWeight: FontWeight.bold,color:Color(0xFF587081)),),
                             ),
                             width(10),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 children: [
                                   Text('${dataService.itemsCart[index]['name']}',style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.bold),),
                                   height(5),
                                   ...dataService.itemsCart[index]['attributes'].map((e){
                                     return Text('${e['name']}',style: TextStyle(
                                       color: Color.fromARGB(255, 68, 71, 71),
                                       fontSize: 11,
                                       fontWeight: FontWeight.w500,
                                     ),);
                                   })
                                 ],
                               ),
                             ),
                             width(15),

                           ],
                         ),
                       ),
                     ],
                   );
                 }),
           ),

              height(30),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lg=='ar'?"رسوم التوصيل":"Frais de livraison",
                        style: TextStyle(fontWeight: FontWeight.w400,color:Color(0xFF587081))
                    ),

                    widget.coupon['delivery_amount']==null?Text(
                        " ${deliveryPrice} ${devic(lang:lg)} ",
                        style:TextStyle(fontWeight:FontWeight.w400,color:Color(0xFF587081))
                    ):Row(
                      children: [
                        widget.coupon['delivery_amount']=="0.00"?Text(" توصيل مجاني",style: TextStyle(
                            color:Colors.green,
                            fontSize:13,
                            fontWeight:FontWeight.w600
                        ),):Text("${widget.coupon['delivery_amount']} ${devic(lang:lg)}"),
                        Text("${deliveryPrice} ${devic(lang:lg)}",style: TextStyle(
                            fontSize:13,
                            fontWeight: FontWeight.w400,color:Color(0xFF587081),
                            decoration:TextDecoration.lineThrough
                        ),),

                      ],
                    ),
                  ],
                ),
              ),
              if(widget.order[0]['weather_fee']!=0)
                height(20),
              if(widget.order[0]['weather_fee']!=0)
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lg=='ar'?"تكاليف الطقس":"Frais de météo",
                        style: TextStyle(fontWeight: FontWeight.w500,color:Color(0xFF587081))
                    ),

                    Row(
                      children: [
                        Text(
                            " ${widget.order[0]['weather_fee']} ${devic(lang:lg)}",
                            style:TextStyle(fontWeight:FontWeight.w500,color:Color(0xFF587081))
                        ),

                      ],
                    )
                  ],
                ),
              ),
              if(widget.order[0]['service_fee']!=0)
                height(20),
              if(widget.order[0]['service_fee']!=0)
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          lg=='ar'?"رسوم الخدمة":"Frais_de_service",
                          style:TextStyle(fontWeight: FontWeight.w500,color:Color(0xFF587081))
                      ),
                      Text(
                          "${(widget.order[0]['service_fee']).toStringAsFixed(2)} ${devic(lang:lg)}",
                          style:TextStyle(fontSize:13,fontWeight: FontWeight.w500,color:Color(0xFF587081))
                      )
                    ],
                  ),
                ),
              height(20),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lg=='ar'?"وسيلة الدفع":"Mode de paiement",
                        style: TextStyle(fontWeight:FontWeight.w500,color:Color(0xFF587081))
                    ),
                    Text(
                        widget.method_payment=='cash'?lg=='ar'?'الدفع عند الاستلام':"Payer en cash":lg=='ar'?'الدفع عن طريق البطاقة':"Payer par carte",
                        style: TextStyle(fontWeight: FontWeight.w500,color: Color(0xFF587081),)
                    )
                  ],
                ),
              ),
              height(20),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lg=='ar'?"المجموع":"Total",
                        style: TextStyle(fontWeight:FontWeight.w400,color:Colors.black)
                    ),
                    widget.coupon['order_amount']==null?Column(
                      children: [
                        widget.coupon['delivery_amount']==null?Text(
                            widget.coupon['percentage']==null?"${(widget.total + deliveryPrice).toStringAsFixed(2)} ${devic(lang:lg)} ":"${(deliveryPrice + widget.total - (widget.total*calculatepercentage(widget.coupon['percentage']))).toStringAsFixed(2)} دراهم ",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFde2706),)
                        ):Text('${(double.tryParse(widget.coupon['delivery_amount']) + widget.total).toStringAsFixed(2)} ${devic(lang: lg)} ',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFde2706),)),
                      ],
                    ):Text("${double.parse(widget.coupon['order_amount'])} ${devic(lang:lg)} ",style: TextStyle(
                      fontWeight: FontWeight.bold,color: Color(0xFFde2706),
                    ),),
                  ],
                ),
              ),


            ],
          ):Padding(
            padding: const EdgeInsets.only(right: 10,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                address == orders[index]?Icon(Icons.location_on_outlined,color:Color(0xFFfb133a)):height(0),
                restaurant == orders[index]?Icon(Icons.home_outlined,color:Color(0xFFfb133a)):height(0),
                address == orders[index] || restaurant == orders[index] ? width(6):height(0),
                address == orders[index]? Expanded(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child:Text(
                              widget.myLocation!=null?"${widget.myLocation}":'موقعي',
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
                ):Text('${orders[index]}',style:TextStyle(fontWeight: FontWeight.w500,fontSize:17),),

                height(5),

              ],
            ),
          ),

        ],
      ),
    ));
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3100),
    );
    itemAnimations = List.generate(
      items.length,
          (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index) / items.length,
            ((index + 1) / items.length),
            curve: Curves.easeIn,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StoreCubit(),
      child: BlocConsumer<StoreCubit, ShopStates>(
       listener: (context,state){
       },
        builder: (context,state){
         return Scaffold(
           bottomNavigationBar: Container(
             height: 100,
             width: double.infinity,
             color: Colors.white,
             child: Column(
               children: [
                 height(20),
                 seconds==0?height(0):
                 seconds == 30?height(0):Center(
                   child: GestureDetector(
                     onTap: (){
                       timer.cancel();
                       if(widget.routing == 'register'){
                         Navigator.of(context).pushAndRemoveUntil(
                             MaterialPageRoute(
                                 builder: (context) => Home(
                                   myLocation:myLocation,
                                   latitude:latitude,
                                   longitude:longitude,
                                 )), (
                             route) => true);
                       }else{
                         Navigator.of(context).pop();
                       }

                     },
                     child: Padding(
                       padding: const EdgeInsets.only(left:50,right:50),
                       child: Container(
                         height: 55,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(30),
                             border: Border.all(width: 1,color: Colors.grey[400])
                         ),
                         child: Center(
                           child: Text(lg=="ar"?'الغاء الطلب':"Annulé la commande",style: TextStyle(
                               fontSize: 14,
                               color: Color(0xFF587081),
                               fontWeight: FontWeight.w400,
                           ),
                             textAlign: TextAlign.center,
                           ),
                         ),
                       ),
                     ),
                   ),
                 )
               ],
             ),
           ),
           backgroundColor: Colors.white,
           appBar: AppBar(
             elevation: 0,
             toolbarHeight: 0,
             backgroundColor: Colors.white,
             automaticallyImplyLeading: false,
           ),
           body: SingleChildScrollView(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 height(10),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Padding(
                       padding: const EdgeInsets.only(right: 20,left: 20),
                       child: Text(lg=='fr'?'en cours de création':"جاري انشاء طلبك",style: TextStyle(
                           fontSize: 23,
                           fontWeight: FontWeight.bold,
                           color: Colors.black
                       )),
                     ),

                     Stack(
                       alignment: Alignment.center,
                       children: [
                         load?Padding(
                           padding: const EdgeInsets.only(left: 20,right: 20),
                           child: Container(
                             height: 70,
                             width: 70,
                             decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 border: Border.all(
                                     color:Color(0xff40826d),
                                     width: 3
                                 )
                             ),
                           ),
                         ):Padding(
                           padding: const EdgeInsets.only(left: 20,right: 20),
                           child:SpinKitRing(
                             lineWidth: 4,
                             color:Color(0xff40826d),
                             size: 70.0,
                           ),
                         ),
                         load?Positioned(child: Icon(Icons.check,size: 40,color:Color(0xff40826d)),right: 15,left: 15,):height(0)
                       ],
                     ),
                   ],
                 ),
                 ListView.builder(
                   physics: NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                   itemCount: items.length,
                   itemBuilder: (context, index) {
                     return AnimatedBuilder(
                       animation: _controller,
                       builder: (context, child) {
                         return Opacity(
                           opacity: itemAnimations[index].value,
                           child: Transform.translate(
                             offset: Offset(0, 50 * (1 - itemAnimations[index].value)),
                             child: child,
                           ),
                         );
                       },
                       child:items[index],
                     );
                   },
                 ),


               ],
             ),
           ),
         );
        },

      ),
    );
  }
  double calculatepercentage(percentage){
    percentage = percentage / 100;
    return percentage;
  }
  String devic({lang}){
    if(lang =='ar'){
      return "درهم";
    }else{
      return "MAD";
    }
  }
}
