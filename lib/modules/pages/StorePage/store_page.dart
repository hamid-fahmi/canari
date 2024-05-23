
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/class/storeCategoriesItem.dart';
import 'package:shopapp/modules/pages/StorePage/placeholder.dart';
import 'package:shopapp/modules/pages/Order/checkout_page.dart';
import 'package:shopapp/shared/components/components.dart';
import '../../../Layout/HomeLayout/selectAddres.dart';
import '../../../localization/demo_localization.dart';
import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';
import '../ProduitDetails/product_detail.dart';
import 'package:flutter_share/flutter_share.dart';
import 'dart:io' show Platform;
const productHeight = 120.0;


class StorePage extends StatefulWidget {
  final String name;
  final String slug;
  final String cover;
  final String brandlogo;
  final dynamic price_delivery;
  final  oldprice_delivery;
  final String deliveryTime;
  final int rate;
  final dynamic service_fee;
  List<dynamic> cuisines = [];
  List<dynamic> tags = [];
  int id;
  List<dynamic> paymentMethods = [];
  StorePage({
    Key key,
    this.oldprice_delivery,
    this.cover,
    this.name,
    this.price_delivery,
    this.rate,
    this.deliveryTime,
    this.cuisines,
    this.id,
    this.tags,
    this.brandlogo,
    this.slug,
    this.service_fee,
    this.paymentMethods
  }) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

    class _StorePageState extends State<StorePage> {
      Future<void> Getconf() async{
        http.Response response = await http.get(Uri.parse('https://api.canariapp.com/v1/client/config'),
        ).then((value)async{
          var responsebody = jsonDecode(value.body);
          setState((){
          responsebody.forEach((e){
            if(e['key']=='weather_fee'){
              print(e);
              dataService.weather_fee = int.parse(e['value']);
              print(dataService.weather_fee);
            }
            if(e['key']=='service_fee_calculation'){
              dataService.value = e['value'];
            }
          });
          });
        }).catchError((onError){

        });
        return response;
      }
       getAllProducts(categories) {
        var products = [];
        for (var category in categories) {
          for (var product in category['products']) {
            products.add(product);
          }
        }
        return products;
      }

      bool ServiceStatus;
      final scrollController = ScrollController();
      bool isShow = false;

      Future<bool>serviceStatus() async {
        RemoteConfig remoteConfig = RemoteConfig.instance;
        remoteConfig.setConfigSettings(RemoteConfigSettings(
            fetchTimeout: Duration(seconds: 60),
            minimumFetchInterval: Duration(seconds: 1)
        ));
        await remoteConfig.fetchAndActivate();
        bool remoteConfigVersion = remoteConfig.getBool('serviceStatus');
        ServiceStatus = remoteConfigVersion;
        setState(() {

        });

        return remoteConfigVersion;

      }

    int selectCategoryIndex = 0;
    bool isScroller = false;


   

    double resturantInfoHeight = 195 + 52 - kToolbarHeight; //Appbar height
    var price;
    var address;
 
    bool isExited = false;


    List<double>breackPoints = [];

    final GlobalKey<FormState> containerKey = GlobalKey<FormState>();
    @override
    void initState() {
      Getconf();
      serviceStatus();
      super.initState();
    }
      Future<void> share() async {
        if (Platform.isAndroid) {
          await FlutterShare.share(
            title: 'Canari food and More',
            text: 'مرحباً ، لقد وجدت هذا المطعم ${widget.name} في كناري. الطعام يبدو جيدًا! إلق نظرة',
            linkUrl: 'https://play.google.com/store/apps/details?id=com.canari.app',
          );
        } else if (Platform.isIOS) {
          await FlutterShare.share(
            title: 'Canari food and More',
            text: 'مرحباً ، لقد وجدت هذا المطعم ${widget.name} في كناري. الطعام يبدو جيدًا! إلق نظرة',
            linkUrl: 'https://apps.apple.com/ma/app/canari-food-delivery/id6448685108',
          );
        }
      }
    @override
    Widget build(BuildContext context) {

      String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
      removeFromCart({id}){
        dataService.itemsCart.where((element) => element['id']==id).forEach((element){
          setState(() {
            if (element['quantity'] > 1) {
              element['quantity']=element['quantity'] - 1;
            }
          });
        });
      }
      double latitud = Cachehelper.getData(key: "latitude");
      String MyLocation = Cachehelper.getData(key: "myLocation");
      return BlocProvider(
        create: (BuildContext context) => StoreCubit()..getStoreData(
            slug:widget.slug,
          )..getCartItem(),
        child: BlocConsumer<StoreCubit, ShopStates>(
          listener: (context, state) {

          },
          builder: (context, state) {
            var cubit = StoreCubit.get(context);
            List<dynamic> OfferProducts = [];

            if(cubit.store!=null){
               if(cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length > 0){
                 var productsid = cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'];
                 printFullText(productsid.toString());

                 var allProducts = getAllProducts(cubit.store['menus']);
                 for (dynamic id in productsid){
                   allProducts.forEach((product){
                     if (product['id'] == id['id'] && OfferProducts.where((element) => element['id']==product['id']).toList().length==0){
                       OfferProducts.add(product);
                     }
                   });
                 }
               }

                double firstBreackPoint = resturantInfoHeight + 15 + (125 * cubit.store['menus'][0]['products'].length);
                breackPoints.add(firstBreackPoint);
                for(var i = 1;i<cubit.store['menus'].length;i++){
                  double breackPoint = breackPoints.last + 15 +(125 * cubit.store['menus'][i]['products'].length);
                  breackPoints.add(breackPoint);
                }
                scrollController.addListener((){
                  for(var i=0;i<cubit.store['menus'].length;i++){
                    if(i==0){
                      if((scrollController.offset < breackPoints.first)&(selectCategoryIndex!=0)){
                        setState(() {
                          selectCategoryIndex =0;
                        });
                      }
                    }else if((breackPoints[i-1]<=scrollController.offset)&(scrollController.offset<breackPoints[i])){
                      if(selectCategoryIndex!=i){
                        setState(() {
                          selectCategoryIndex = i;
                        });
                      }
                    }
                  }
                  if (scrollController.offset > 180) {
                    setState(() {
                      isShow = true;
                    });
                  } else {
                    setState(() {
                      isShow = false;
                    });
                  }
                });
              }







      return SafeArea(
        child: StreamBuilder<ConnectivityResult>(
          stream: Connectivity().onConnectivityChanged,
          builder:(context,snapshot){
            return Scaffold(
                backgroundColor: Colors.white,
                bottomNavigationBar:
                state is!GetResturantPageDataLoadingState ? cubit.getCartItem() != 0
                    ? Container(
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
                    padding: const EdgeInsets.only(
                        right: 15, left: 15, bottom: 10, top: 10),
                    child: GestureDetector(
                      onTap: () async{
                        if (cubit.store['is_open']==false){
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
                          if (latitud != null) {
                            var totalPrice = await navigateTo(
                              context,CheckoutPage(
                              rout:service_type,
                              store:cubit.store,
                              paymentMethods:widget.paymentMethods,
                              service_fee:widget.service_fee,
                              olddelivery_price: widget.oldprice_delivery,
                              delivery_price: widget.price_delivery,
                            ));
                            setState(() {
                              totalPrice = price;
                            });
                          } else {
                            final changeAdress = await navigateTo(
                                context,
                                SelectAddres(
                                  routing: 'restaurantPage',
                                  rout:service_type,
                                  store:cubit.store,
                                  paymentMethods:widget.paymentMethods,
                                  service_fee:widget.service_fee,
                                  olddelivery_price: widget.oldprice_delivery,
                                  delivery_price: widget.price_delivery,
                                ));
                            setState(() {
                              if (changeAdress != null) {
                                MyLocation = changeAdress;
                              }
                            });
                          }
                        }},
                      child: Container(
                        height:50,
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
                    : SizedBox(
                  height: 0,
                )
                    : SizedBox(
                  height: 0,
                ),
                body: state is! GetResturantPageDataLoadingState ?
                CustomScrollView(
                  controller: scrollController,
                  slivers:[
                    SliverAppBar(
                      toolbarHeight:isShow ? 50:0,
                      elevation: 0,
                      expandedHeight: 0,
                      pinned: true,
                      centerTitle: true,
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isShow ? '${widget.name}' : '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isShow ? 'Livraison dans 20-30 min':"",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      actions: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10,left:10),
                              child: GestureDetector(
                                onTap: () {
                                  share();
                                },
                                child: CircleAvatar(
                                    child: Icon(Icons.share,
                                        color: Colors.black, size: 24),
                                    backgroundColor: Colors.white,
                                    minRadius: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, '${cubit.getTotalPrice()}');
                              setState(() {

                              });
                            },
                            child: CircleAvatar(
                                child: Icon(Icons.arrow_back,color: Colors.black, size: 26),
                                backgroundColor: Colors.white,
                                minRadius: 22),
                          ),

                        ],
                      ),
                    ),
                    SliverPadding(padding:
                    const EdgeInsets.symmetric(horizontal: 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 210,
                                color: Colors.white,
                                child: Stack(
                                  alignment: AlignmentDirectional.bottomStart,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 220,
                                            color: Colors.black,
                                            child: Opacity(
                                              opacity: cubit.store['is_open'] != false
                                                  ? 0.3
                                                  : 1,
                                              child:CachedNetworkImage(
                                                  width: double.infinity,
                                                  imageUrl:'${widget.cover}',
                                                  placeholder:(context,url)=>
                                                      Image.asset(
                                                        'assets/placeholder.png',
                                                        fit:BoxFit.cover,
                                                      ),
                                                  errorWidget: (context,url,error)=>
                                                  Image.asset(
                                                  'assets/placeholder.png',
                                                  fit: BoxFit.cover,
                                                  ),
                                                  imageBuilder: (context, imageProvider) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10,top: 5,left: 10),
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(3, 3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context,'${cubit.getTotalPrice()}');
                                                      setState(() {
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 8,top: 6,left:8),
                                                      child: CircleAvatar(radius: 20,child: Icon(Icons.arrow_back,
                                                          color: Colors.black, size: 24),
                                                        backgroundColor: Colors.white,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8,top: 5,left:8),
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(3, 3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      share();
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10,top: 6,right:10),
                                                      child: CircleAvatar(radius: 20,child: Icon(Icons.share,
                                                          color: Colors.black, size: 24),
                                                        backgroundColor: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )

                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15,left: 10),
                                          child: Container(
                                            decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.5),
                                              child: Text('LIVRAISON GRATUIE',style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400
                                              ),),
                                            ),

                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15,left: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                              borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.5),
                                              child: Text('COMMANDE MIN 25 MAD',style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:12,
                                                  fontWeight: FontWeight.w400
                                              ),),
                                            ),

                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Padding(
                                    //   padding: const EdgeInsets.only(left: 30,right: 30),
                                    //   child: Container(
                                    //     height: 135,
                                    //     width: double.infinity,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.red,
                                    //       borderRadius: BorderRadius.circular(8),
                                    //       border: Border.all(
                                    //           color: Colors.grey[300],
                                    //           width: 0.9
                                    //       ),
                                    //     ),
                                    //     child: Column(
                                    //       crossAxisAlignment: CrossAxisAlignment.start,
                                    //       children: [
                                    //         Row(
                                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //           children: [
                                    //             Row(
                                    //               children: [
                                    //                 Padding(
                                    //                   padding: const EdgeInsets.all(8.0),
                                    //                   child: Container(
                                    //                     width: 65,
                                    //                     height: 65,
                                    //                     decoration: BoxDecoration(
                                    //                       borderRadius: BorderRadius.circular(5),
                                    //                     ),
                                    //                     child:ClipRRect(
                                    //                       borderRadius: BorderRadius.circular(5),
                                    //                       child:CachedNetworkImage(
                                    //                           imageUrl: '${widget.brandlogo}',
                                    //                           placeholder: (context, url) =>
                                    //                               Image.asset('assets/placeholder.png',fit: BoxFit.cover),
                                    //                           errorWidget: (context, url, error) => const Icon(Icons.error),
                                    //                           imageBuilder: (context, imageProvider){
                                    //                             return Container(
                                    //                               decoration: BoxDecoration(
                                    //                                 image: DecorationImage(
                                    //                                   image: imageProvider,
                                    //                                   fit: BoxFit.cover,
                                    //                                 ),
                                    //                               ),
                                    //                             );
                                    //                           }
                                    //                       ),
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //                 width(4),
                                    //                 Column(
                                    //                   crossAxisAlignment: CrossAxisAlignment.start,
                                    //                   children: [
                                    //                     Text('${widget.name}',style: TextStyle(
                                    //                         fontWeight: FontWeight.bold,
                                    //                         fontSize: 16
                                    //                     )),
                                    //                     Wrap(
                                    //                       crossAxisAlignment: WrapCrossAlignment.start,
                                    //                       children: [
                                    //                         Text('${widget.cuisines.take(4).map((item) => item['name']).join(' , ')}',style: TextStyle(
                                    //                           fontSize: 10,
                                    //                           fontWeight: FontWeight.w500,
                                    //                           color: Colors.grey[400],
                                    //                         ),)
                                    //                       ],
                                    //                     ),
                                    //                   ],
                                    //                 )
                                    //               ],
                                    //             ),
                                    //
                                    //             if(widget.tags.length>0)
                                    //             Padding(
                                    //                 padding: const EdgeInsets.only(left: 8,right: 8),
                                    //                 child: Container(
                                    //                   decoration: BoxDecoration(
                                    //                     borderRadius: BorderRadius.circular(5),
                                    //                     color: Color(0xfffafafa),
                                    //                   ),
                                    //                   child: Padding(
                                    //                     padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                    //                     child: Text(DemoLocalization.of(context).getTranslatedValue('nouveau'),
                                    //                       style:TextStyle(
                                    //                           color:Color(0xffff7144),
                                    //                           fontSize: 12,
                                    //                           fontWeight: FontWeight.bold
                                    //                       ),),
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //           ],
                                    //         ),
                                    //         Row(
                                    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //           children: [
                                    //             Column(
                                    //               children: [
                                    //                 Text(DemoLocalization.of(context).getTranslatedValue('Frais_de_livraison'),style: TextStyle(
                                    //                     fontSize: 11,
                                    //                     color: Colors.grey[600]
                                    //                 ),),
                                    //                 height(5),
                                    //                 cubit.ispriceLoading?Row(
                                    //                   children: [
                                    //                     Text(
                                    //                         cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                    //                             style: TextStyle(
                                    //                             fontSize:10,
                                    //                             fontWeight: FontWeight.bold,color: AppColor)
                                    //                     ),
                                    //
                                    //                     if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                    //                       width(4),
                                    //                     if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                    //                       Text(' ${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',
                                    //                           style: TextStyle(
                                    //                               decoration: TextDecoration.lineThrough,
                                    //                               fontSize:10.2,
                                    //                               fontWeight: FontWeight.w500,
                                    //                               color: Colors.grey[400]
                                    //                           )
                                    //                       )
                                    //                   ],
                                    //                 ):Row(
                                    //                   children: [
                                    //                     SpinKitThreeBounce(
                                    //                       color: Colors.grey[400],
                                    //                       size: 20.0,
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //             Container(
                                    //                 height: 30,
                                    //                 width: 1,
                                    //                 color:Colors.grey[300]
                                    //             ),
                                    //             Column(
                                    //               children: [
                                    //                 Text(DemoLocalization.of(context).getTranslatedValue('État_du_restaurant'),style: TextStyle(
                                    //                     fontSize: 11,
                                    //                     color:Colors.grey[600]
                                    //                 ),),
                                    //                 height(5),
                                    //
                                    //                 Text(cubit.store['is_open'] != false?DemoLocalization.of(context).getTranslatedValue('ouvrir'):DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(
                                    //                   fontSize: 10.5,
                                    //                   fontWeight: FontWeight.bold,
                                    //                 ),)
                                    //               ],
                                    //             ),
                                    //             Container(
                                    //                 height: 30,
                                    //                 width: 1,
                                    //                 color:Colors.grey[300]
                                    //             ),
                                    //             GestureDetector(
                                    //               child: Column(
                                    //                 children: [
                                    //                   Icon(Icons.info,size:14,color:Colors.grey[400]),
                                    //                   height(5),
                                    //                   Text(DemoLocalization.of(context).getTranslatedValue('plus_de_détails'),style: TextStyle(
                                    //                     fontSize: 10.5,
                                    //                     fontWeight: FontWeight.bold,
                                    //                   ),)
                                    //                 ],
                                    //               ),
                                    //               onTap:(){
                                    //                 showModalBottomSheet(
                                    //                     isScrollControlled: true,
                                    //                     context: context, builder:(context){
                                    //                   return restaurantInfo(cubit:cubit);
                                    //                 } );
                                    //               }
                                    //             ),
                                    //           ],
                                    //         )
                                    //       ],
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                              !isShow?height(10):height(0),
                              !isShow? Padding(
                               padding: const EdgeInsets.only(left: 10,top: 2),
                               child: Column(
                                 crossAxisAlignment:CrossAxisAlignment.start,
                                 mainAxisAlignment:MainAxisAlignment.start,
                                 children: [
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Text('${widget.name}',style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20
                                       )),
                                       Padding(
                                         padding: const EdgeInsets.only(right: 8),
                                         child: Row(
                                           children: [
                                             Icon(Icons.star,size:12,color: Colors.amber),
                                             Text('3.5 Excellent',style: TextStyle(
                                               fontWeight: FontWeight.bold,
                                               fontSize:11,
                                               color: Colors.red,

                                             ),)
                                           ],
                                         ),
                                       )
                                     ],
                                   ),
                                   height(7),
                                   Text('${widget.cuisines.take(4).map((item) => item['name']).join(' , ')}',style: TextStyle(
                                     fontSize:12,
                                     fontWeight: FontWeight.w500,
                                     color: Colors.grey[400],
                                   ),),


                                 ],
                               ),
                             ):height(0),
                            ],
                          ),
                        )),
                    if(cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length > 0)
                    SliverPadding(
                        padding:EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:EdgeInsets.only(right: 10,top: 10,bottom: 10,left: 10),
                                    child: Row(
                                      children: [
                                        Image.asset('assets/discount.png',height: 20),
                                        width(2),
                                        Text('${cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['name']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                          ),
                                          textDirection:TextDirection.ltr,
                                        ),
                                      ],
                                    ),
                                  ),
                                  cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['description']==''?height(0):Padding(
                                    padding:EdgeInsets.only(right: 10,top: 0,bottom: 5,left: 10),
                                    child: Text('${cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['description']}'),
                                  ),
                                  height(5),

                                  OfferProducts.length>0? Container(
                                    height: 190,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child:ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: OfferProducts.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context,index){
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: ()async{
                                                  if(OfferProducts[index]['modifierGroups'].length == 0) {
                                                    var totalPrice = await showModalBottomSheet(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                                        ),
                                                        isScrollControlled: true,
                                                        context: context,
                                                        builder: (context) {
                                                          StoreName = cubit.store['name'];
                                                          StoreId = cubit.store['id'];
                                                          deliveryPrice = widget.price_delivery;
                                                          storeStatus = cubit.store['is_open'];
                                                          cubit.qty = 1;

                                                          return buildProduct(
                                                              OfferProducts[index],
                                                              cubit,
                                                              StoreName,
                                                              StoreId,
                                                              deliveryPrice,
                                                              storeStatus,
                                                              offers:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                              prixOffer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((e)=>e['id']==OfferProducts[index]['id']).first['sale_price']);
                                                        });
                                                    setState(() {
                                                      totalPrice = price;
                                                    });
                                                  }else{
                                                    printFullText(OfferProducts[index]['modifierGroups'].toString());
                                                    StoreName = cubit.store['name'];
                                                    StoreId = cubit.store['id'];
                                                    deliveryPrice = widget.price_delivery;
                                                    storeStatus = cubit.store['is_open'];
                                                    cubit.qty = 1;
                                                    var totalPrice = await navigateTo(context,ProductDetail(
                                                        id: StoreId,
                                                        StoreName: StoreName,
                                                        DeliveryPrice:deliveryPrice,
                                                        dishes:OfferProducts[index],
                                                        storeStatus:storeStatus,
                                                        offer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                        prixOffer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==OfferProducts[index]['id']).toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==OfferProducts[index]['id']).toList()[0]['sale_price']:null:null
                                                    ));
                                                    setState(() {
                                                      totalPrice = price;
                                                    });
                                                  }

                                              },
                                              child: Container(
                                                width: 160,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:110,
                                                      width: 170,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child:OfferProducts[index]['image']==''?
                                                      ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight:Radius.circular(8)),
                                                          child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)):
                                                      CachedNetworkImage(
                                                          imageUrl: '${OfferProducts[index]['image']}',
                                                          placeholder: (context, url) =>
                                                              ClipRRect(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,width: 90,height: 90,)),
                                                          errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight:Radius.circular(8)),
                                                              child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
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
                                                    Padding(padding: EdgeInsets.only(right: 8,top: 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('${OfferProducts[index]['name']}',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),maxLines:2,overflow:TextOverflow.ellipsis),
                                                          height(5),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 5),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children:[
                                                                Text("${cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((e)=>e['id']==OfferProducts[index]['id']).first['sale_price']} درهم ",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color:AppColor),),
                                                                 Text('${OfferProducts[index]['price']} درهم ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color:Colors.grey[400],decoration: TextDecoration.lineThrough),),

                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ):height(0)
                                ]),
                          ),
                        ),
                      ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StoreCategoriesItem(
                          isShow :isShow,
                          cubit: cubit,
                          selectedIndex: selectCategoryIndex,
                          onchanged: (int index) {
                            if (selectCategoryIndex != index) {
                              int totalItems = 0;
                              for (var i = 0; i < index; i++) {
                                totalItems += cubit.store['menus'][i]['products'].length;
                              }
                              scrollController.animateTo(
                                  resturantInfoHeight +
                                      (130 * totalItems) +
                                      (20 * index),
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            }
                            setState(() {
                              selectCategoryIndex = index;
                            });
                          }),
                    ),
                    SliverPadding(

                      padding: const EdgeInsets.symmetric(horizontal: 0),

                      sliver: SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              cubit.store['menus'].length == 0
                                  ? Padding(
                                padding:
                                const EdgeInsets.only(top: 0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'نحن نعمل على ادراج هذا المتجر ، تعال قريبًا',
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    height(20),
                                    LinearProgressIndicator(
                                        color: AppColor,
                                        backgroundColor:
                                        Color(0xFFFFCDD2)),
                                  ],
                                ),
                              )
                                  : SizedBox(height: 0),
                              Container(
                                color: Colors.grey[100],
                                child: Column(
                                  children: [
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: cubit.store['menus'].length,
                                        itemBuilder: (context, int index) {
                                          return Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 10, top: 0),
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 16,right: 10,left: 10),
                                                    child: Text(
                                                      '${capitalize('${cubit.store['menus'][index]['name']}')}',
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  height(10),
                                                  Column(
                                                    children: [
                                                      cubit.store['view_type']=='row'?ListView.builder(
                                                          shrinkWrap: true,
                                                          physics: NeverScrollableScrollPhysics(),
                                                          itemCount: cubit.store['menus'][index]['products'].length,
                                                          itemBuilder: (BuildContext context, productindex){

                                                            var product = cubit.store['menus'][index]['products'][productindex];
                                                            var contain = dataService.itemsCart.where((element) =>
                                                            element['id'] == product['id']).toList();
                                                            if (contain.isEmpty) {
                                                              isExited = false;
                                                            } else {
                                                              isExited = true;
                                                            }
                                                            return Container(
                                                              color: Colors.white,
                                                              child:Column(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment:MainAxisAlignment.start,
                                                                children:[
                                                                  Container(
                                                                    height:productHeight,
                                                                    color: Colors.white,
                                                                    child: InkWell(
                                                                      onTap: () async {
                                                                        if(product['modifierGroups'].length == 0) {
                                                                          var totalPrice = await showModalBottomSheet(
                                                                              shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                                                              ),
                                                                              isScrollControlled: true,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                StoreName = cubit.store['name'];
                                                                                StoreId = cubit.store['id'];
                                                                                deliveryPrice = widget.price_delivery;
                                                                                storeStatus = cubit.store['is_open'];
                                                                                cubit.qty = 1;
                                                                                return buildProduct(
                                                                                    product,
                                                                                    cubit,
                                                                                    StoreName,
                                                                                    StoreId,
                                                                                    deliveryPrice,
                                                                                    storeStatus,
                                                                                    offers:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                                    prixOffer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList()[0]['sale_price']:null:null
                                                                                );
                                                                              });
                                                                                setState(() {
                                                                                  totalPrice = price;
                                                                                });
                                                                               }
                                                                               else{
                                                                                StoreName = cubit.store['name'];
                                                                                StoreId = cubit.store['id'];
                                                                                deliveryPrice = widget.price_delivery;
                                                                                olddeliveryPrice = widget.oldprice_delivery;
                                                                                storeStatus = cubit.store['is_open'];
                                                                                var totalPrice = await navigateTo(context,ProductDetail(
                                                                                  id: StoreId,
                                                                                  StoreName: StoreName,
                                                                                  DeliveryPrice:deliveryPrice,
                                                                                  dishes: product,
                                                                                  storeStatus: storeStatus,
                                                                                  offer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                                  prixOffer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList()[0]['sale_price']:null:null
                                                                                ));
                                                                                setState(() {
                                                                                  totalPrice = price;
                                                                                });
                                                                              }
                                                                              },
                                                                      child: Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          isExited
                                                                              ? Padding(
                                                                            padding: const EdgeInsets.only(top: 15),
                                                                              child: Container(
                                                                                height: 90,
                                                                                width: 2.7,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(50),
                                                                                  color: AppColor,
                                                                                )),
                                                                          )
                                                                              : height(0),
                                                                          width(6),
                                                                          isExited
                                                                              ? Padding(
                                                                            padding: EdgeInsets.only(
                                                                              top: 20,
                                                                            ),
                                                                            child: Container(
                                                                              height: 23,
                                                                              width: 23,
                                                                              decoration: BoxDecoration(color: AppColor, shape: BoxShape.circle, boxShadow: [
                                                                                BoxShadow(color: Colors.grey[300], offset: Offset(2, 1), blurRadius: 2, spreadRadius: 1)
                                                                              ]),
                                                                              child: Center(
                                                                                  child: contain.length > 0
                                                                                      ? Text(
                                                                                    'x${contain[0]['quantity']}',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                                                                                  )
                                                                                      : height(0)),
                                                                            ),
                                                                          )
                                                                              : height(0),
                                                                          width(4),
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  product['name'] == null ? '' : '${product['name']}',
                                                                                  maxLines: 2,
                                                                                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                height(8),
                                                                                Text(
                                                                                  product['description'] == null ? '' : '${product['description']}',
                                                                                  maxLines: 2,
                                                                                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                height(8),
                                                                                OfferProducts.length>0?Column(children: [
                                                                                  cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList().length>0?
                                                                                  Row(
                                                                                    children: [
                                                                                      Text('${cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList()[0]['sale_price']} درهم ',style: TextStyle(
                                                                                        fontWeight: FontWeight.w400,
                                                                                        color:Colors.grey[600],
                                                                                        fontSize: 14,
                                                                                      )),
                                                                                      width(10),
                                                                                      Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style:TextStyle(decoration: TextDecoration.lineThrough,fontSize:12))
                                                                                    ],
                                                                                  ):Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style:TextStyle(fontWeight: FontWeight.w400, color:Colors.grey[600],fontSize: 14,))
                                                                                ],):Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(
                                                                                        color: Colors.red,
                                                                                  fontWeight: FontWeight.w500
                                                                                         ),),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          width(15),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(top:25,right:7),
                                                                            child: Container(
                                                                              width: 130,
                                                                              height: 80,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                child: product['image'] == ''
                                                                                    ? height(0)
                                                                                    : CachedNetworkImage(
                                                                                    imageUrl: '${product['image']}',
                                                                                    placeholder: (context, url) => Image.asset('assets/placeholder.png', fit: BoxFit.cover),
                                                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                    imageBuilder: (context, imageProvider) {
                                                                                      return Container(
                                                                                        decoration: BoxDecoration(
                                                                                          image: DecorationImage(
                                                                                            image: imageProvider,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  height(3),
                                                                  Container(
                                                                    height:0.5,
                                                                    width:double.infinity,
                                                                    color:Colors.grey[350],
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                      )

                                                          :
                                                      GridView.builder(
                                                       shrinkWrap:true,
                                                       physics: NeverScrollableScrollPhysics(),
                                                       itemCount: cubit.store['menus'][index]['products'].length,
                                                       itemBuilder: (BuildContext context,productindex) {
                                                         var product = cubit.store['menus'][index]['products'][productindex];
                                                         var contain = dataService.itemsCart.where((element) =>
                                                         element['id'] == product['id']).toList();
                                                         if (contain.isEmpty) {
                                                           isExited = false;
                                                         } else {
                                                           isExited = true;
                                                         }
                                                         return Padding(
                                                           padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom:10),
                                                           child: Container(
                                                             color: Colors.white,
                                                             child:Column(
                                                               crossAxisAlignment: CrossAxisAlignment.center,
                                                               mainAxisAlignment:MainAxisAlignment.start,
                                                               children:[
                                                                 InkWell(
                                                                   onTap: () async {
                                                                     if(product['modifierGroups'].length==0){
                                                                       var totalPrice = await showModalBottomSheet(
                                                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                                                           isScrollControlled: true,
                                                                           context: context,
                                                                           builder: (context) {
                                                                             StoreName =cubit.store['name'];
                                                                             StoreId = cubit.store['id'];
                                                                             deliveryPrice = cubit.store['delivery_price'];
                                                                             storeStatus = cubit.store['is_open'];
                                                                             cubit.qty = 1;
                                                                             return buildProduct(
                                                                               product,
                                                                               cubit,
                                                                               StoreName,
                                                                               StoreId,
                                                                               deliveryPrice,
                                                                               storeStatus,
                                                                               offers:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                             );
                                                                           });
                                                                       setState(() {
                                                                         totalPrice = price;
                                                                       });
                                                                     }
                                                                     else{
                                                                       StoreName = cubit.store['name'];
                                                                       StoreId = cubit.store['id'];
                                                                       deliveryPrice =cubit.store['delivery_price'];
                                                                       olddeliveryPrice = cubit.store['delivery_old_price'];
                                                                       storeStatus = cubit.store['is_open'];
                                                                       var totalPrice = await navigateTo(context,ProductDetail(
                                                                           id:StoreId,
                                                                           StoreName:StoreName,
                                                                           DeliveryPrice:deliveryPrice,
                                                                           dishes: product,
                                                                           storeStatus: storeStatus,
                                                                           offer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                           prixOffer:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList()[0]['sale_price']:null:null
                                                                       ));
                                                                       setState(() {
                                                                         totalPrice = price;
                                                                       });
                                                                     }
                                                                   },
                                                                   child: Padding(
                                                                     padding: const EdgeInsets.all(4.0),
                                                                     child: Container(
                                                                       child:product['image']!=''?ClipRRect(
                                                                         borderRadius:BorderRadius.circular(7),
                                                                         child:Padding(
                                                                           padding:const EdgeInsets.all(8.0),
                                                                           child:CachedNetworkImage(
                                                                               imageUrl:"${product['image']}",
                                                                               placeholder: (context, url) =>
                                                                                   ClipRRect(
                                                                                       borderRadius:BorderRadius.circular(7),
                                                                                       child: Image.asset('assets/placeholder.png',fit:BoxFit.cover,)),
                                                                               errorWidget: (context, url, error) => ClipRRect(
                                                                                   borderRadius:BorderRadius.circular(7),
                                                                                   child: Image.asset('assets/placeholder.png',fit:BoxFit.cover,)),
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
                                                                       )
                                                                           :ClipRRect(
                                                                           borderRadius:BorderRadius.circular(7),
                                                                           child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
                                                                       height: 150,
                                                                       width: 150,
                                                                       decoration: BoxDecoration(
                                                                           borderRadius: BorderRadius.circular(7),
                                                                           border: Border.all(color: Colors.grey[300],width: 0.5)
                                                                       ),
                                                                     ),
                                                                   ),
                                                                 ),
                                                                 height(5),
                                                                 Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style:TextStyle(
                                                                   fontWeight: FontWeight.bold,fontSize: 13.5,
                                                                 ),),
                                                                 height(5),
                                                                 Text('${product['name']}',style: TextStyle(
                                                                     fontWeight: FontWeight.w400,fontSize: 13.5,
                                                                     overflow:TextOverflow.ellipsis,
                                                                     color: Colors.grey[500]
                                                                 ),maxLines:2,textAlign: TextAlign.center,
                                                                 ),
                                                                 isExited?
                                                                 Padding(
                                                                   padding: const EdgeInsets.only(left: 0,right: 0,bottom: 15,top: 5),
                                                                   child: Container(
                                                                     decoration: BoxDecoration(
                                                                       borderRadius: BorderRadius.circular(8),
                                                                       color: Colors.white,
                                                                       boxShadow: [
                                                                         BoxShadow(
                                                                             color: Colors.grey[200],
                                                                             offset: Offset(1,2),
                                                                             spreadRadius: 1,
                                                                             blurRadius: 1
                                                                         )
                                                                       ],
                                                                     ),
                                                                     height:40,width:double.infinity,
                                                                     child: Row(
                                                                       crossAxisAlignment: CrossAxisAlignment.center,
                                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                       children:[
                                                                         contain[0]['quantity']==1?TextButton(onPressed: (){
                                                                           setState(() {
                                                                             dataService.itemsCart.removeWhere((element) => element['id']==product['id']);
                                                                           });
                                                                         },child:Icon(Icons.delete,color: Colors.red,size: 22)):TextButton(onPressed: (){
                                                                           removeFromCart(id:product['id']);
                                                                         },child:Icon(Icons.remove,color: Colors.red,size: 22)),




                                                                         width(5),

                                                                         Text('${contain[0]['quantity']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                                                                         width(5),
                                                                         TextButton(
                                                                           onPressed: (){
                                                                             print(cubit.store['id']);
                                                                             print(product['id']);
                                                                             setState(() {
                                                                               cubit.addToCart(
                                                                                 product:product,
                                                                                 attributes: [],
                                                                                 storeName:cubit.store['name'],
                                                                                 storeStats:cubit.store['is_open'],
                                                                                 productStoreId:cubit.store['id'],
                                                                                 productId:product['id'],
                                                                                 Qty:cubit.qty,
                                                                                 offers:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                                 prixOffer:null,
                                                                               );
                                                                             });
                                                                           }, child:Icon(Icons.add,color: Colors.red,size: 22),

                                                                         ),


                                                                       ],
                                                                     ),
                                                                   ),
                                                                 ):
                                                                 Padding(
                                                                   padding: const EdgeInsets.only(top:10,right: 0,),
                                                                   child:Align(
                                                                     child: Container(
                                                                       decoration: BoxDecoration(
                                                                         borderRadius: BorderRadius.circular(8),
                                                                         color: Colors.white,
                                                                         boxShadow: [
                                                                           BoxShadow(
                                                                               color: Colors.grey[200],
                                                                               offset: Offset(1,2),
                                                                               spreadRadius: 1,
                                                                               blurRadius: 1
                                                                           )
                                                                         ],
                                                                       ),
                                                                       height:40,width:40,child:IconButton(
                                                                         onPressed: (){
                                                                           print(cubit.store['id']);
                                                                           print(product['id']);
                                                                           setState(() {
                                                                             cubit.addToCart(
                                                                               product:product,
                                                                               attributes: [],
                                                                               storeName:cubit.store['name'],
                                                                               storeStats:cubit.store['is_open'],
                                                                               productStoreId:cubit.store['id'],
                                                                               productId:product['id'],
                                                                               Qty:cubit.qty,
                                                                               offers:cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                                               prixOffer:null,
                                                                             );
                                                                           });
                                                                         },icon:Icon(Icons.add,size: 22)),
                                                                     ),
                                                                     alignment: Alignment.center,
                                                                   ),
                                                                 )
                                                               ],
                                                             ),
                                                           ),
                                                         );
                                                       },
                                                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                         crossAxisCount: 2,
                                                         crossAxisSpacing: 0.0,
                                                         childAspectRatio: 1/1.5,
                                                         mainAxisSpacing: 0.0,
                                                       ),
                                                     ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ],
                )
                : placeholder());
          },


        ),
        );},
        ),
      );
    }
       Widget infoItem({IconData icon,String infotitel,String InfoDescript}) {
         return Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Row(
               children: [
                 Icon(icon),
                 width(10),
                 Text(infotitel,
                   style: TextStyle(
                       color: Colors.black,
                       fontSize: 15,
                       fontWeight: FontWeight.w500),),
               ],
             ),
             Padding(
               padding: const EdgeInsets.only(top: 5),
               child: Text(InfoDescript,
                 textDirection: TextDirection.ltr,
                 style: TextStyle(
                     color: Color.fromARGB(255, 78, 78, 78),
                     fontSize: 12,
                     fontWeight: FontWeight.w400),
               ),
             ),
           ],
         );
       }

       Widget restaurantInfo({cubit}){
        return  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  color: Colors.black,
                  child: Opacity(
                    opacity: 0.6,
                    child:
                    CachedNetworkImage(
                        height: 250,
                        width: double.infinity,
                        imageUrl: '${widget.cover}',
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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child:CachedNetworkImage(
                              imageUrl: '${widget.brandlogo}',
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              '${widget.name}',
                              style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 52, 52, 52),
                                    ),
                                  ],
                                  color: Colors.white,
                                  fontSize: 20.5,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          height(5),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              Text('${widget.cuisines.map((item) => item['name']).join(' , ')}',style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 52, 52, 52),
                                    ),
                                  ],
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                    width(15),

                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Column(
                children: [
                    height(25),
                  widget.rate<=2?
                  infoItem(icon: Icons.emoji_emotions_outlined,infotitel:DemoLocalization.of(context).getTranslatedValue('normale'),InfoDescript: '${widget.rate} ${DemoLocalization.of(context).getTranslatedValue('Évaluation')} '):infoItem(icon: Icons.emoji_emotions_outlined,infotitel:widget.rate>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),InfoDescript: '${widget.rate} ${DemoLocalization.of(context).getTranslatedValue('Évaluation')} '),
                  if(widget.deliveryTime!=null)
                    height(15),
                  if(widget.deliveryTime!=null)
                    Container(height: 0.1,width:double.infinity ,color: Colors.black,),
                    height(15),
                  if(widget.deliveryTime!=null)
                    infoItem(icon: Icons.delivery_dining_outlined,infotitel:DemoLocalization.of(context).getTranslatedValue('Date_de_livraison'),InfoDescript: '${widget.deliveryTime} ${DemoLocalization.of(context).getTranslatedValue('Second')} '),
                  if(widget.deliveryTime!=null)
                    height(15),
                    Container(height: 0.1,width:double.infinity ,color: Colors.black,),
                    height(15),
                    dataService.payment_by_card? infoItem(icon: Icons.account_balance_wallet_outlined,infotitel: DemoLocalization.of(context).getTranslatedValue('Mode_de_paiement'),InfoDescript:widget.paymentMethods.length!=2?widget.paymentMethods.contains('CASH')?DemoLocalization.of(context).getTranslatedValue('Payer_en_cash'):DemoLocalization.of(context).getTranslatedValue('Payer_par_carte'):DemoLocalization.of(context).getTranslatedValue('Payer_par_Carte_ou_en_Cash')):infoItem(icon: Icons.account_balance_wallet_outlined,infotitel:DemoLocalization.of(context).getTranslatedValue('Mode_de_paiement'),InfoDescript:DemoLocalization.of(context).getTranslatedValue('Payer_en_cash')),
                    height(15),
                    Container(height: 0.1,width:double.infinity ,color: Colors.black,),
                    height(15),
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                       children: [
                       Icon(Icons.delivery_dining_sharp),
                       width(15),
                       Text(DemoLocalization.of(context).getTranslatedValue('Frais_de_livraison'),
                       style: TextStyle(
                       color: Colors.black,
                       fontSize: 15,
                       fontWeight: FontWeight.w500),),
                       ],
                       ),
                         cubit.ispriceLoading? Padding(
                           padding: const EdgeInsets.only(top:8),
                           child:Row(
                             children:[
                               Text(
                                   cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                   style: TextStyle(
                                       fontSize:10.5,
                                       fontWeight: FontWeight.bold,color: AppColor)
                               ),
                               if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                 width(4),
                               if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                 Text(' ${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',
                                     style:TextStyle(
                                         decoration: TextDecoration.lineThrough,
                                         fontSize:10.2,
                                         fontWeight: FontWeight.w500,
                                         color: Colors.grey[400]
                                     )
                                 )
                             ],
                           ),
                         ):Row(
                           children: [
                             SpinKitThreeBounce(
                               color: Colors.grey[400],
                               size: 20.0,
                             ),
                           ],
                         ),
                      ],
                ),

                ],
              ),
            )
          ],
        );
       }

       Container devider() {
      return Container(
        height: 8,
        color: Colors.grey[100],
        width: double.infinity,
      );
    }

   Widget buildProduct(product,cubit,StoreName,StoreId,deliveryPrice,storeStatus,{dynamic prixOffer,offers}){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          height(10),
          Row(
            mainAxisAlignment:prixOffer!=null?MainAxisAlignment.spaceBetween:MainAxisAlignment.start,
            children: [
                  prixOffer!=null? Padding(
                    padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
                    child: Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color:Colors.grey[400],decoration: TextDecoration.lineThrough),),
                  ):height(0),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
                    child: Text('${prixOffer==null?product['price']:prixOffer} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
                  ),
            ],
          ),


          height(20),
          StatefulBuilder(builder:(context,setState){
           return Container(
             decoration: BoxDecoration(
                 color: Colors.white,
                ),
             height: 75,
             child: Padding(
               padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 10),
               child: GestureDetector(
                 onTap: (){
                   StoreName = StoreName;
                   StoreId = StoreId;
                   deliveryPrice = deliveryPrice;
                     cubit.addToCart(
                     product:product,
                     Qty:cubit.qty,
                     productStoreId:StoreId,
                     attributes:[],
                     storeStats: storeStatus,
                     offers:offers,
                     storeName:StoreName,
                     prixOffer:prixOffer!=null?int.parse(prixOffer):double.parse(product['price'])
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
                         offers:offers,
                         storeName:StoreName,
                         prixOffer:prixOffer!=null?int.parse(prixOffer):double.parse(product['price'])
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
                         height: 50,
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

}
double calculatePrice(price,percentage){
  percentage = percentage / 100;
  return price - (price * percentage);
}
