import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/modules/Register/register.dart';
import 'package:shopapp/modules/pages/Order/order.dart';
import 'package:shopapp/modules/pages/Order/paymentPage.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/modules/pages/PrivacyPolicy/paymentPolicy.dart';
import 'package:shopapp/shared/components/components.dart';
import '../../../Layout/HomeLayout/selectAddres.dart';
import '../../../Layout/shopcubit/storecubit.dart';
import '../../../Layout/shopcubit/storestate.dart';
import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';
import '../cartPage/cart_empty.dart';
import 'package:flutter/services.dart';

import 'operationOrder.dart';

class CheckoutPage extends StatefulWidget {
  final rout;
  final delivery_price;
  final olddelivery_price;
  var service_fee;
  List<dynamic> paymentMethods = [];
  final store;
   CheckoutPage({Key key, this.delivery_price,this.olddelivery_price,this.service_fee,this.paymentMethods, this.store, this.rout}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

List<String>options=["cash","card"];
class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormState> inputkey = GlobalKey<FormState>();
  bool isEnable;
  var total = 0.0;
  var price ;
   void check()async{
     var IsnotificationEnable = await Permission.notification.status;
     print('============================================');
     setState(() {
       isEnable = IsnotificationEnable.isGranted;

     });
     print('============================================');
   }
 @override
  void initState() {
    check();
    super.initState();
  }

  bool isvalidtime(int startDay,int endDay){
    DateTime currentDateTime = DateTime.now();
    print(currentDateTime);
    if (currentDateTime.hour >= endDay && currentDateTime.hour < startDay){
      print('The app is sleeping');
      return false;
    }else {
      print('The app is currently active');
      return true;

    }

  }

  Completer<GoogleMapController> _controller = Completer();
   bool isAccepted = true;
   bool isShow = false;
  Future<void> animateCamera(latitude,longitude)async{
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
        target:LatLng(latitude,longitude),
        zoom: 18.4746
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  TextEditingController NoteController = TextEditingController();
  TextEditingController CouponController = TextEditingController();
  TextEditingController EmailController = TextEditingController();
  String access_token = Cachehelper.getData(key: "token");

  var adress;
  bool isPaymentLoading = true;

  totalprice(products){
    double totalPrice = 0.0;
    List<dynamic> itemProducts = products['attributes'];
    for (var product in itemProducts) {
      totalPrice += double.tryParse(product['price']);
    }
    return totalPrice;
  }
  String currentOption = options[0];

   Checkout(payload)async{
     setState(() {
       isPaymentLoading =false;
     });
     http.Response response = await http.post(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
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
    String access_token = Cachehelper.getData(key: "token");

    animateCamera(latitud,longitud);
    Set<Marker>myMarkers={
      Marker(
        draggable: true,
        onDragEnd:(LatLng latLng){},
        markerId: MarkerId('1'),
        position:LatLng(latitud, longitud),
      )
    };
    return BlocProvider(
        create: (BuildContext context) => StoreCubit(),
        child: BlocConsumer<StoreCubit, ShopStates>(
          listener: (context,state){
           if(state is MyorderSucessfulState){
             navigateTo(context,Order(order: state.order));
           }
          },
          builder: (context,state){
            var cubit = StoreCubit.get(context);
            var subTotal = cubit.getTotalPrice();

            String device_id = Cachehelper.getData(key:"deviceId");

            return StreamBuilder<ConnectivityResult>(
              stream: Connectivity().onConnectivityChanged,
              builder: (context,snapshot){

                return Scaffold(
                    bottomSheet:snapshot.data==ConnectivityResult.none?buildNoNetwork():height(0),
                    bottomNavigationBar:
                    dataService.itemsCart.length!=0?Summary(context,cubit,isloading:isPaymentLoading,isAccpted:isAccepted,
                        rout: DemoLocalization.of(context).getTranslatedValue('Compléter_une_commande'),
                        ontap: (){
                          List<Map<String, dynamic>> modifiedList = [{
                            "restaurant":StoreName,
                            "address": MyLocation,
                            "totalPrice":cubit.coupon['percentage']!=null?(subTotal - (subTotal*calculatepercentage(cubit.coupon['percentage']))).toStringAsFixed(2):dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee+subTotal,
                            "deliveryPrice":cubit.coupon['delivery_amount'],
                            "weather_fee":dataService.weather_fee,
                            "service_fee":dataService.value!='sum'? subTotal * (widget.service_fee / 100):widget.service_fee,
                          }];
                          if(peak_time_status=='middle'){
                            showDialog(context: context, builder:(context){
                              return StatefulBuilder(
                                builder: (BuildContext context,setState) {
                                  return Dialog(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              height: 180,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  bottomLeft: Radius.circular(0),
                                                  bottomRight:Radius.circular(0),
                                                  topRight:Radius.circular(5),
                                                ),
                                              ),
                                              child:ClipRRect(
                                                  borderRadius:BorderRadius.circular(5),
                                                  child:Image.asset('assets/canari-cook.jpg',fit: BoxFit.cover,))
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                                            child: Text(DemoLocalization.of(context).getTranslatedValue('note'),textAlign: TextAlign.center,style: TextStyle(
                                                fontSize: 14.5,
                                                height: 1.3,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromARGB(255, 37, 23, 18)
                                            )),
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(left: 15,right: 15,top: 0,bottom: 13),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: (){
                                                    print(isAccepted);
                                                    setState((){
                                                      if(access_token==null){
                                                       if (isAccepted) {
                                                             Navigator.pop(context);
                                                             navigateTo(context,Register(
                                                                    coupon: cubit.coupon,
                                                                     service_fee:dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee,
                                                                     wether_fee: dataService.weather_fee,
                                                                     paymentMethod: currentOption,
                                                                     NoteController: NoteController,
                                                                     total:subTotal,
                                                                     CouponController: CouponController));
                                                          }
                                                      }else{
                                                        if(currentOption == 'cash'){
                                                          print(subTotal);
                                                          access_token==null?navigateTo(context,Register(
                                                            emailController:EmailController,
                                                            coupon:cubit.coupon,
                                                            service_fee:dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee,
                                                            wether_fee:dataService.weather_fee,
                                                            paymentMethod:currentOption,
                                                            NoteController:NoteController,total:subTotal,CouponController: CouponController,)):
                                                          navigateTo(context,AnimatedListView(
                                                            coupon:cubit.coupon,
                                                            emailController:EmailController,
                                                            method_payment:currentOption,
                                                            order:modifiedList,myLocation:MyLocation,total:subTotal,deliveryPrice:deliveryPrice,note:NoteController.text,CouponController:CouponController.text,));
                                                        }else{
                                                          if (isAccepted) {
                                                            access_token ==
                                                                null
                                                                ? navigateTo(
                                                                context,
                                                                Register(
                                                                  emailController:EmailController,
                                                                  coupon: cubit.coupon,
                                                                  service_fee:dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee,
                                                                  wether_fee: dataService.weather_fee,
                                                                  paymentMethod: currentOption,
                                                                  NoteController: NoteController,
                                                                  total:cubit.coupon['delivery_amount'] == null
                                                                      ? cubit.coupon['percentage'] != null
                                                                      ? (subTotal - (subTotal * calculatepercentage(cubit.coupon['percentage'])))
                                                                      : subTotal : double.tryParse(cubit.coupon['delivery_amount']) + subTotal,
                                                                  CouponController: CouponController,))
                                                                : navigateTo(context,AnimatedListView(
                                                              emailController:EmailController,
                                                              coupon: cubit.coupon,
                                                              method_payment: currentOption,
                                                              order: modifiedList,
                                                              myLocation: MyLocation,
                                                              total:cubit.coupon['delivery_amount'] == null ? cubit.coupon['percentage'] != null ? (subTotal - (subTotal * calculatepercentage(cubit.coupon['percentage']))) : subTotal : double.tryParse(cubit.coupon['delivery_amount']) + subTotal,
                                                              deliveryPrice: deliveryPrice,
                                                              note: NoteController.text,
                                                              CouponController: CouponController.text,));
                                                          }
                                                        }
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color:isAccepted==true?AppColor:Colors.grey,
                                                    ),
                                                    height: 50,
                                                    width: 120,
                                                    child: Center(child:isPaymentLoading?Text(DemoLocalization.of(context).getTranslatedValue('Compléter_une_commande'),textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:14,
                                                          fontWeight:FontWeight.w500
                                                      ),):CircularProgressIndicator(color: Colors.white,)),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    decoration:BoxDecoration(
                                                        border:Border.all(width: 1.5,color:Colors.grey[400]),
                                                        borderRadius:BorderRadius.circular(5),
                                                        color:Colors.white
                                                    ),
                                                    height:50,
                                                    width:120,
                                                    child:Center(child: Text(DemoLocalization.of(context).getTranslatedValue('Annuler_la_commande'),textAlign: TextAlign.center,style: TextStyle(
                                                        color:Colors.grey[500],
                                                        fontSize:14,
                                                        fontWeight:FontWeight.w500
                                                    ),)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            });
                          }
                          else{
                            if(currentOption == 'cash'){
                              print(dataService.value);
                              access_token==null?navigateTo(context,Register(
                                coupon:cubit.coupon,
                                service_fee:dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee,
                                wether_fee:dataService.weather_fee,
                                emailController:EmailController,
                                paymentMethod:currentOption,
                                NoteController:NoteController,total:dataService.value!='sum'?(subTotal+(subTotal * (widget.service_fee / 100))):widget.service_fee+subTotal,CouponController: CouponController,)):
                              navigateTo(context, AnimatedListView(
                                coupon:cubit.coupon,
                                emailController:EmailController,
                                method_payment:currentOption,
                                order:modifiedList,myLocation:MyLocation,total:dataService.value!='sum'?(subTotal+(subTotal * (widget.service_fee / 100))):widget.service_fee+subTotal,deliveryPrice:deliveryPrice,note:NoteController.text,CouponController:CouponController.text,));
                            }else{
                              if(isAccepted){
                                access_token==null?navigateTo(context,Register(
                                  coupon:cubit.coupon,
                                  emailController:EmailController,
                                  service_fee:dataService.value!='sum'?subTotal * (widget.service_fee / 100):widget.service_fee,
                                  wether_fee:dataService.weather_fee,
                                  paymentMethod:currentOption,
                                  NoteController:NoteController,total:dataService.value!='sum'?(subTotal+(subTotal * (widget.service_fee / 100))):widget.service_fee+subTotal,CouponController: CouponController,))
                                    :
                                navigateTo(context,AnimatedListView(
                                  coupon:cubit.coupon,
                                  emailController:EmailController,
                                  method_payment:currentOption,
                                  order:modifiedList,myLocation:MyLocation,total:dataService.value!='sum'?(subTotal+(subTotal * (widget.service_fee / 100))):widget.service_fee+subTotal,deliveryPrice:deliveryPrice,note:NoteController.text,CouponController:CouponController.text,
                                ));

                              }
                            }
                          }

                        }):SizedBox(height: 0),
                    backgroundColor: Colors.white,
                    appBar:
                    AppBar(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      title:Text(
                        DemoLocalization.of(context).getTranslatedValue('Pay'),
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                      leading: GestureDetector(
                        onTap: () async{
                        var totalprice = await Navigator.pop(context,'${cubit.getTotalPrice()}');
                        setState(() {
                          totalprice = price;
                        });
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),

                    ),
                    body:dataService.itemsCart.length!=0?
                   SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20,top: 0,right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Vos_produits'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:FontWeight.w500,
                                    ),
                                  ),
                                  width(5),
                                  Text('(${dataService.itemsCart.length})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              height(10),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: dataService.itemsCart.length,
                                  itemBuilder: (context,index){
                                     totalprice(dataService.itemsCart[index]);
                                     print(dataService.itemsCart);
                                    return Padding(
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('x${dataService.itemsCart[index]['quantity']}',style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColor
                                                ),),
                                                width(5),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${dataService.itemsCart[index]['name']}',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:Colors.black, fontWeight: FontWeight.bold),
                                                      ),

                                                      height(8)
                                                    ],
                                                  ),
                                                ),
                                                width(15),
                                                if(dataService.itemsCart[index]['offers']!=null)

                                                   Text('${dataService.itemsCart[index]['priceold']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 13,
                                                      decoration: TextDecoration.lineThrough,
                                                      color:Colors.grey[400]
                                                  )),
                                                width(10),
                                                Text('${(dataService.itemsCart[index]['price'])+totalprice(dataService.itemsCart[index])} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                )),
                                              ],
                                            ),
                                            dataService.itemsCart[index]['attributes'].length>0? Padding(
                                              padding: const EdgeInsets.only(left: 20,bottom: 10),
                                              child: Text(
                                                '${dataService.itemsCart[index]['attributes'].map((item) => item['name']).join(' + ')}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(255, 68, 71, 71),
                                                ),
                                              ),
                                            ):height(5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                  maxRadius: 17,
                                                  backgroundColor:Color(0xFFffe1e6),
                                                  child: IconButton(
                                                      splashRadius: 22,
                                                      onPressed:(){
                                                    setState((){
                                                      cubit.DecrementCart(product:dataService.itemsCart[index]);
                                                    });
                                                  }, icon:Icon(Icons.remove,size: 19,color: Colors.red,)),
                                                ),
                                                CircleAvatar(
                                                  maxRadius: 17,
                                                  backgroundColor:Color(0xFFffe1e6),
                                                  child: IconButton(
                                                      splashRadius: 22,
                                                      onPressed: (){
                                                        setState((){
                                                          cubit.IncrementCart(product:dataService.itemsCart[index]);
                                                        });
                                                      }, icon:Icon(Icons.add,size: 19,color: AppColor,)),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                  }),
                              Row(
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Détails_de_livraison'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              height(10),
                              Container(
                                width: double.infinity,
                                child:Column(
                                  children:[
                                    Container(
                                      height:100,
                                      width:double.infinity,
                                      child:ClipRRect(
                                        borderRadius:BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0),
                                          topRight: Radius.circular(6)
                                        ),
                                        child:GoogleMap(
                                          onTap:(LatLng latLng)async{
                                            final changeAdress = await navigateTo(context, SelectAddres(routing: 'checkout',));
                                            setState(() {
                                              if(changeAdress!=null){
                                                myLocation = changeAdress;
                                              }
                                            });
                                          },
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(latitud, longitud),
                                            zoom: 15.2356,
                                          ),
                                          markers: myMarkers,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: ()async{
                                        final changeAdress = await navigateTo(context, SelectAddres(routing: 'checkout',));
                                        setState(() {
                                          if(changeAdress!=null){
                                            myLocation = changeAdress;
                                          }
                                          print(changeAdress);
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                                    child: Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13),),
                                                  ),
                                                  height(3),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                                    child: Row(
                                                      children: [
                                                        Expanded(child:Text(
                                                          MyLocation!=null? "${MyLocation}":DemoLocalization.of(context).getTranslatedValue('Choisissez_un_emplacement'),
                                                          textAlign: TextAlign.start,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 11),
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: ()async{
                                                final changeAdress = await navigateTo(context, SelectAddres(routing: 'checkout',));
                                                setState(() {
                                                  if(changeAdress!=null){
                                                    myLocation = changeAdress;
                                                  }
                                                  print(changeAdress);
                                                });

                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color:Colors.grey[50],
                                                    borderRadius: BorderRadius.circular(5)
                                                ),
                                                child: Center(child: Padding(
                                                  padding: const EdgeInsets.only(left: 2,right: 5),
                                                  child: Row(
                                                    children:[
                                                      Text(DemoLocalization.of(context).getTranslatedValue('Changer_emplacement'),style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 13),),
                                                      Icon(Icons.location_on_outlined,size: 25,color: Colors.red,)
                                                    ],
                                                  ),
                                                )),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color:Colors.grey[300],width: 0.8)
                                ),
                              ),
                              height(15),
                              Row(
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Ajouter_des_notes'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              height(10),

                              Padding(
                                padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                child:TextFormField(
                                  controller: NoteController,
                                  maxLines:1,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:Colors.grey[50],
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        width: 0.8,
                                        color:Colors.grey[200],
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        width: 0.8,
                                        color:Colors.grey[200],
                                      ),
                                    ),
                                    hintText:DemoLocalization.of(context).getTranslatedValue('Écrivez_vos_notes_ici'),
                                    labelStyle: TextStyle(
                                      color: Color(0xFF7B919D)
                                    ),
                                    hintStyle: TextStyle(
                                      color:Color(0xFF7B919D),
                                    ),
                                  ),
                                ),
                              ),

                              if(coupon_page)
                                height(15),
                              if(coupon_page)
                                Row(
                                  children: [
                                    Text(DemoLocalization.of(context).getTranslatedValue('Code_coupon'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:FontWeight.w500,
                                      ),
                                    ),
                                    width(3),
                                    Text(DemoLocalization.of(context).getTranslatedValue('Optionnel'),style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:FontWeight.w500,
                                    ),)
                                  ],
                                ),
                              if(coupon_page)
                                height(20),
                              if(coupon_page)
                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  child: TextFormField(
                                    inputFormatters:[new LengthLimitingTextInputFormatter(6),],
                                    onChanged:(value)async{
                                      if(value.length==6){
                                        StoreCubit.get(context).CheckCoupons(value);
                                      }
                                      else{
                                        StoreCubit.get(context).isValid = null;
                                        cubit.coupon['percentage']=null;
                                        cubit.coupon['delivery_amount']=null;
                                        cubit.coupon['order_amount']=null;
                                        setState(() {

                                        });
                                      }
                                    },
                                    controller:CouponController,
                                    keyboardType: TextInputType.name,

                                    maxLines:1,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      suffixIcon:state is CheckCouponsLoadingState?CircleAvatar(
                                              backgroundColor: Colors.transparent,
                                              maxRadius: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: CircularProgressIndicator(color: Colors.blue,),
                                              )):ValideIcon(StoreCubit.get(context).isValid),
                                      filled: true,
                                      fillColor:Colors.grey[50],
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          width: 0.8,
                                          color:Colors.grey[200],
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          width: 0.8,
                                          color:Colors.grey[200],
                                        ),
                                      ),
                                      hintText:DemoLocalization.of(context).getTranslatedValue('Entrez_le_code_promo_ici'),

                                      labelStyle: TextStyle(
                                          color: Color(0xFF7B919D)
                                      ),
                                      hintStyle: TextStyle(
                                        color:Color(0xFF7B919D),
                                      ),
                                    ),
                                  ),
                                ),


                              if(coupon_page)
                                StoreCubit.get(context).isValid == null?height(0):height(8),
                              if(coupon_page)
                                Row(
                                  children: [
                                    StoreCubit.get(context).isValid == false ? StoreCubit.get(context).isValid == null?SizedBox(height: 0): Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(DemoLocalization.of(context).getTranslatedValue('Code_coupon_invalide'),style: TextStyle(color:Colors.red,fontWeight: FontWeight.w500,fontSize: 13),)):SizedBox(height: 0),
                                  ],
                                ),
                              height(20),
                             Row(
                               children: [
                                 Text(DemoLocalization.of(context).getTranslatedValue('Méthode_de_paiement'),style: TextStyle(
                                   fontSize: 16,
                                   fontWeight:FontWeight.w500,
                                 ),),
                               ],
                             ),
                              height(10),
                              Container(
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(5),
                                 border:Border.all(
                                   color:Colors.grey[300],
                                   width: 0.6,
                                 ),
                               ),
                               child:Column(
                                 children:[
                                   widget.paymentMethods.contains('CASH')?RadioListTile(
                                     activeColor:AppColor,
                                     value:options[0],
                                     groupValue:currentOption,
                                     onChanged:(value) {
                                       setState((){
                                         currentOption = value.toString();
                                         setState(() {
                                           isShow = false;
                                           isAccepted = true;
                                         });
                                       });
                                     },
                                     title:Text(DemoLocalization.of(context).getTranslatedValue('Payer_en_cash')),
                                     secondary:Icon(Icons.payments_outlined),
                                   ):height(0),
                                   widget.paymentMethods.contains('CASH') && widget.paymentMethods.contains('CARD') ? Column(
                                     children: [
                                       dataService.payment_by_card? Divider():height(0),
                                     ],
                                   ):height(0),
                                   widget.paymentMethods.contains('CARD')?Column(
                                     children: [
                                       dataService.payment_by_card? RadioListTile(
                                         activeColor:AppColor,
                                         value:options[1],
                                         groupValue:currentOption,
                                         onChanged: (value){
                                           setState(() {
                                             print(currentOption);
                                             currentOption = value.toString();
                                             isShow = true;
                                             setState(() {
                                               isAccepted = false;
                                             });
                                             });
                                         },
                                         title: Text(DemoLocalization.of(context).getTranslatedValue('Payer_par_carte')),
                                         secondary:Directionality(
                                           textDirection: TextDirection.ltr,
                                           child:Image.asset('assets/logo-cmi-open.png',height: 50,width: 50,),
                                         )
                                       ):height(0),
                                     ],
                                   ):height(0),

                                 ],
                               ),
                             ),

                              dataService.payment_by_card?height(10):height(0),
                              isShow?
                              Form(
                                key:inputkey,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  child: TextFormField(
                                    maxLines:1,
                                    controller:EmailController,
                                    style: TextStyle(color: Colors.black),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return DemoLocalization.of(context).getTranslatedValue('Ne_doit_pas_être_vide');
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:Colors.grey[50],
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          width: 0.8,
                                          color:Colors.grey[200],
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          width: 0.8,
                                          color:Colors.grey[200],
                                        ),
                                      ),
                                      hintText:DemoLocalization.of(context).getTranslatedValue('Entrez_votre_email'),
                                      hintStyle: TextStyle(
                                        color:Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              ):height(0),
                              isShow?CheckboxListTile(
                                activeColor:AppColor,
                                contentPadding: EdgeInsets.only(right: 0,top: 10),
                                  title:RichText(
                                    text: TextSpan(
                                    children: <TextSpan>[
                                    TextSpan(
                                    text: DemoLocalization.of(context).getTranslatedValue('Jaccepte_les_conditions_générales'),
                                      style: TextStyle(color: Colors.black,height: 1.5)
                                    ),
                                      TextSpan(
                                          text:DemoLocalization.of(context).getTranslatedValue('et_jai_lu_la'),
                                          style: TextStyle(color: Colors.black,height: 1.5)
                                      ),
                                      TextSpan(
                                          text:DemoLocalization.of(context).getTranslatedValue('politique_de_vente'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              navigateTo(context, PaymentPolicy());
                                            },
                                          style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline,height: 2)


                                      ),
                                    ])

                                  ),
                                  value:isAccepted,
                                  onChanged:(value){
                                  setState(() {
                                    isAccepted = !isAccepted;
                                  });
                                }):height(0),
                              height(8),
                              Padding(
                                padding: const EdgeInsets.only(left: 5,top: 12,right: 5),
                                child:Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                DemoLocalization.of(context).getTranslatedValue('Sous_total'),
                                                style:TextStyle(fontWeight: FontWeight.w400,color: Colors.grey)
                                            ),
                                              cubit.coupon['percentage']==null? Text(
                                                "${subTotal} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                style:TextStyle(fontWeight: FontWeight.w400,color: Colors.black)
                                            ):Row(
                                              children: [
                                                Text("${(subTotal - (subTotal*calculatepercentage(cubit.coupon['percentage']))).toStringAsFixed(2)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ", style: TextStyle(fontWeight:FontWeight.w600,color: Colors.green)),
                                                Text(
                                                    "${subTotal} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                    style:TextStyle(fontSize:13,fontWeight: FontWeight.w400,color: Colors.black,decoration:TextDecoration.lineThrough)
                                                )
                                              ],
                                            ),

                                          ],
                                        ),
                                        height(15),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                DemoLocalization.of(context).getTranslatedValue('Frais_de_livraison'),
                                                style: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey)
                                            ),

                                            cubit.coupon['delivery_amount']==null?Text(
                                                " ${deliveryPrice} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                style:TextStyle(fontWeight:FontWeight.w400,color:Colors.black)
                                            ):Row(
                                              children: [
                                                Text(cubit.coupon['delivery_amount']=="0.00"?" ${DemoLocalization.of(context).getTranslatedValue('livraison_gratuite')}  ":" ${cubit.coupon['delivery_amount']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",style: TextStyle(
                                                    color:Colors.green,
                                                    fontSize:13,
                                                    fontWeight:FontWeight.w600
                                                ),),
                                                Text("${deliveryPrice} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",style: TextStyle(
                                                    fontSize:13,
                                                    fontWeight: FontWeight.w400,color: Colors.black,
                                                    decoration:TextDecoration.lineThrough
                                                ),),

                                              ],
                                            ),
                                          ],
                                        ),
                                        if(dataService.weather_fee!=0)
                                        height(15),
                                        if(dataService.weather_fee!=0)
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                DemoLocalization.of(context).getTranslatedValue('Frais_de_météo'),
                                                style:TextStyle(fontWeight: FontWeight.w400,color: Colors.grey)
                                            ),
                                            Text(
                                                "${dataService.weather_fee} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                style:TextStyle(fontSize:13,fontWeight: FontWeight.w400,color: Colors.black,)
                                            )
                                          ],
                                        ),
                                        if(widget.service_fee!=0)
                                        height(15),
                                        if(widget.service_fee!=0)
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                DemoLocalization.of(context).getTranslatedValue('Frais_de_service'),
                                                style:TextStyle(fontWeight: FontWeight.w400,color: Colors.grey)
                                            ),
                                            dataService.value!='sum'?Text(
                                                "${subTotal * (widget.service_fee / 100)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                style:TextStyle(fontSize:13,fontWeight: FontWeight.w400,color: Colors.black,)
                                            ):Text(
                                                "${widget.service_fee} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                style:TextStyle(fontSize:13,fontWeight: FontWeight.w400,color: Colors.black,)
                                            )
                                          ],
                                        ),
                                        height(15),
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                DemoLocalization.of(context).getTranslatedValue('Total'),
                                                style: TextStyle(fontWeight:FontWeight.w400,color:Colors.black)
                                            ),
                                            cubit.coupon['order_amount']==null?Column(
                                              children: [
                                                cubit.coupon['delivery_amount']==null?Text(
                                                    cubit.coupon['percentage']==null?"${subTotal + dataService.weather_fee + deliveryPrice + (dataService.value!='sum'?(subTotal * (widget.service_fee / 100)):widget.service_fee)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ":"${(deliveryPrice + subTotal - (subTotal*calculatepercentage(cubit.coupon['percentage']))).toStringAsFixed(2)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",
                                                    style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFde2706),)
                                                ):Text('${double.tryParse(cubit.coupon['delivery_amount']) + subTotal} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFde2706),)),
                                              ],
                                            ):Text("${double.parse(cubit.coupon['order_amount'])} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ",style: TextStyle(
                                              fontWeight: FontWeight.bold,color: Color(0xFFde2706),
                                            ),),
                                          ],
                                        ),
                                        height(10),
                                      ],
                                    ),
                                    height(10),
                                  ],
                                ),
                              ),
                              height(10)
                            ],
                          )

                      ),
                    ):Cartempty(rout:widget.rout)

                );
              },

            );
          },

        ),
      );
  }

  double calculatePrice(price,percentage){
    percentage = percentage / 100;
    return price + (price * percentage);
  }

  double calculatepercentage(percentage){
    percentage = percentage / 100;
    return percentage;
  }
}

