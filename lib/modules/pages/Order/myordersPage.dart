import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/modules/pages/Order/order.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'dart:ui' as ui;
import '../../../Layout/HomeLayout/selectAddres.dart';
import '../../../Layout/shopcubit/storecubit.dart';
import '../../../localization/demo_localization.dart';
import '../../../shared/components/components.dart';
import '../../../shared/network/remote/cachehelper.dart';
import 'checkout_page.dart';
class MyorderPage extends StatefulWidget {
  const MyorderPage({Key key}) : super(key: key);

  @override
  State<MyorderPage> createState() => _MyorderPageState();
}

class _MyorderPageState extends State<MyorderPage> with TickerProviderStateMixin{

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
  AnimationController controller;
  final List<String> products = [
    "1 x Pizza Margarita",
    "1 x Pizza Végétarienne",
    "1 x Pizza Poulet",
    "1 x Pizza Viande haché",
    "1 x Pizza Fruit de mer",
    "1 x Pizza au Thon",
    "1 x Pizza 4 Saisons",
    "1 x Pizza Favorita",
    "1 x Pizza Dinde",
  ];
  final int maxVisibleProducts = 1;
  @override
  Widget build(BuildContext context) {
    Future<void>firebaseMessagingBackgroundHandler(RemoteMessage message,)async{
      if (message.notification!=null) {
       printFullText(message.notification.body);
      }
    }

    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message){
      if (message.notification!=null) {
      }


    },);
    return BlocProvider(
      create: (BuildContext context) => StoreCubit()..Myorders(),
      child: BlocConsumer<StoreCubit,ShopStates>(
          listener: (context,state){
           if(state is MyorderSucessfulState){
             navigateTo(context,Order(
               order:state.order,
             ));
           }
          },
          builder: (context,state){
            String device_id = Cachehelper.getData(key:"deviceId");
            String MyLocation = Cachehelper.getData(key: "myLocation");

            var cubit = StoreCubit.get(context);
            return Scaffold(
              backgroundColor: Colors.white,
              appBar:
              AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  DemoLocalization.of(context).getTranslatedValue('Mes_demandes'),
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              body:cubit.isload?cubit.myorders.length>0?
              ListView.builder(
                physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cubit.myorders.length,
                  itemBuilder: (context,index){
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: InkWell(
                          radius: 10,
                          borderRadius:BorderRadius.circular(5),
                          onTap: () async {
                            cubit.Myorder(cubit.myorders[index]['order_ref']);
                            cubit.isloading = false;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Opacity(
                                        opacity:cubit.myorders[index]['store']['is_open']?1:0.5,
                                        child: CachedNetworkImage(
                                            height: 80,
                                            width:80,
                                            imageUrl: '${cubit.myorders[index]['store']['logo']}',
                                            placeholder: (context, url) =>
                                                Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                            imageBuilder: (context, imageProvider){
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
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
                                    cubit.myorders[index]['store']['is_open']==true?height(0):
                                    Text(DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2.0, 2.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 52, 52, 52),
                                        ),
                                      ],
                                    ),)
                                  ],
                                ),
                                width(15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       Text(
                                        '${cubit.myorders[index]['store']['name']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF000000),
                                            fontSize: 15.5),

                                       ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:cubit.myorders[index]['products'].length > maxVisibleProducts
                                                ? maxVisibleProducts + 1
                                                :cubit.myorders[index]['products'].length,
                                          shrinkWrap:true,
                                          itemBuilder:(context,prodIndex){
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text('x${cubit.myorders[index]['products'][prodIndex]['quantity']}',style:TextStyle(fontSize: 13.5,fontWeight: FontWeight.w300,color:Colors.grey),),
                                            ),
                                            width(10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  height(3),
                                                  Row(
                                                    children: [
                                                      Expanded(child: Text('${cubit.myorders[index]['products'][prodIndex]['name']}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w300,color:Colors.grey),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                      if(prodIndex == maxVisibleProducts)
                                                        width(5),
                                                      if(prodIndex == maxVisibleProducts)
                                                        Text('...',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color:Colors.grey),)
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            width(15),
                                          ],
                                        );
                                      }),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${cubit.myorders[index]['total'].toStringAsFixed(2)} ${DemoLocalization.of(context).getTranslatedValue('MAD')}',style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),),

                                          cubit.myorders[index]['status']=='delivered'?height(0):Text(status(cubit.myorders[index]['status']),style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: Color(0xff10a37f),
                                          ),),
                                          if(cubit.myorders[index]['status']=='delivered')
                                           Container(
                                             height: 35,
                                             decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                               color:cubit.myorders[index]['store']['is_open']?AppColor:Colors.blueGrey,
                                               boxShadow: [
                                                 BoxShadow(
                                                   color: Colors.grey[300],
                                                   offset: Offset(0,2),
                                                   spreadRadius:1,
                                                   blurRadius: 2
                                                 )
                                               ]
                                             ),
                                             child: TextButton(
                                               onPressed: ()async{
                                                 StoreName = cubit.myorders[index]['store']['name'];
                                                 StoreId = cubit.myorders[index]['store']['id'];
                                                 deliveryPrice = cubit.myorders[index]['store']['delivery_price'];
                                                 olddeliveryPrice = cubit.myorders[index]['store']['delivery_price_old'];
                                                 service_fee = cubit.myorders[index]['store']['service_fee'];
                                                 paymentMethods = cubit.myorders[index]['store']['payment_methods'];
                                                 dataService.itemsCart = cubit.myorders[index]['products'];

                                                 if(cubit.myorders[index]['store']['is_open']){
                                                   for(var i = 0; i < cubit.myorders[index]['products'].length; i++){
                                                     cubit.myorders[index]['products'][i]['productStoreId'] = StoreId;
                                                     cubit.myorders[index]['products'][i]['latitud']=cubit.myorders[index]['delivery_address']['latitude'];
                                                     cubit.myorders[index]['products'][i]['longitud']=cubit.myorders[index]['delivery_address']['longitude'];
                                                     cubit.myorders[index]['products'][i]['MyLocation']=cubit.myorders[index]['delivery_address']['label'];
                                                   }
                                                   StoreName = cubit.myorders[index]['store']['name'];
                                                   StoreId = cubit.myorders[index]['store']['id'];
                                                   deliveryPrice = cubit.myorders[index]['store']['delivery_price'];
                                                   dataService.itemsCart = cubit.myorders[index]['products'];
                                                   for (var i = 0; i < cubit.myorders[index]['products'].length; i++) {
                                                     cubit.myorders[index]['products'][i]['productStoreId'] = StoreId;
                                                   }
                                                   print(MyLocation);
                                                   if(MyLocation==null){
                                                     final changeAdress = await navigateTo(context, SelectAddres(routing: 'checkout',));
                                                     setState(() {
                                                       if(changeAdress!=null){
                                                         MyLocation = changeAdress;
                                                       }
                                                     });
                                                   }
                                                   else{
                                                     navigateTo(context,CheckoutPage(
                                                       rout:service_type,
                                                       store:cubit.myorders[index]['store'],
                                                       service_fee:service_fee,
                                                       olddelivery_price:olddeliveryPrice,
                                                       paymentMethods:paymentMethods,
                                                       delivery_price: deliveryPrice,
                                                     ));

                                                   }
                                                  } else{
                                                   ScaffoldMessenger.of(context)
                                                       .showSnackBar(SnackBar(
                                                     content: Text(
                                                       DemoLocalization.of(context).getTranslatedValue('Cest_un_restaurant_fermé'),
                                                       style: TextStyle(
                                                           fontSize: 16,
                                                           fontWeight: FontWeight.bold),
                                                       textDirection: ui.TextDirection.rtl,
                                                     ),
                                                     duration: Duration(milliseconds: 1000),
                                                   ));
                                                 }

                                               },
                                               child: Text(DemoLocalization.of(context).getTranslatedValue('Commande_Again'),style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 11,
                                               )),
                                             ),

                                           )
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
                    ),
                  ],
                );

              }):
              Center(child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(Icons.fastfood_outlined,size: 120,color: Color(0xFF6b7280)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
                    child: Text('ليس لديك أي طلبات حتى الآن. جرب أحد مطاعمنا الرائعة',style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
                  ),
                  height(50),
                ],
              ),):
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator(color: AppColor,))
                ],
              ),
            );
          },

      )

    );
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

}
