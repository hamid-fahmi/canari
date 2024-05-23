import 'package:buildcondition/buildcondition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/HomeLayout/selectAddres.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/network/remote/cachehelper.dart';
import 'dart:io' show Platform;
import '../../Layout/shopcubit/storecubit.dart';
import '../../Layout/shopcubit/storestate.dart';
import '../../modules/pages/Order/checkout_page.dart';
import '../../modules/pages/ProduitDetails/product_detail.dart';
import '../../shared/components/constants.dart';
import 'market_details.dart';

class LayoutMarket extends StatefulWidget {
  const LayoutMarket({Key key}) : super(key: key);

  @override
  State<LayoutMarket> createState() => _LayoutMarketState();
}

class _LayoutMarketState extends State<LayoutMarket>{
  final scrollController = ScrollController();
  var price;

  double latitud = Cachehelper.getData(key: "latitude");
  String MyLocation = Cachehelper.getData(key: "myLocation");

  removeFromCart({id}){
    print(id);
    dataService.itemsCart.where((element) => element['id']==id).forEach((element){
      setState(() {
        if (element['quantity'] > 1) {
          element['quantity']=element['quantity'] - 1;
        }

      });
    });
  }

  bool isShow = false;
  bool isExited = false;
  @override
  void initState(){
    super.initState();
  }
  Future<void> share({name}) async {
    if (Platform.isAndroid) {
      await FlutterShare.share(
        title: 'Canari food and More',
        text: 'مرحباً ، لقد وجدت هذا المطعم ${name} في كناري. الطعام يبدو جيدًا! إلق نظرة',
        linkUrl: 'https://play.google.com/store/apps/details?id=com.canari.app',
      );
    } else if (Platform.isIOS) {
      await FlutterShare.share(
        title: 'Canari food and More',
        text: 'مرحباً ، لقد وجدت هذا المطعم ${name} في كناري. الطعام يبدو جيدًا! إلق نظرة',
        linkUrl: 'https://apps.apple.com/ma/app/canari-food-delivery/id6448685108',
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (BuildContext context) => StoreCubit()..getStoreData(
        slug:grocery_market_id,
      ),
      child: BlocConsumer<StoreCubit,ShopStates>(
        listener: (context,state){},
        builder: (context,state){
          var cubit = StoreCubit.get(context);
          if(cubit.store!=null){
            cubit.store['group_products'].forEach((e){
              e['quantity']=1;
            });
          }
          var restaurantsWithDiscount = cubit.stores.where((restaurant) {
            List<dynamic> offers = restaurant['offers'];
            return offers.any((offer) => offer['type'] != "freeDeliveryFirstOrder");
          }).toList();
          scrollController.addListener((){
            if (scrollController.offset > 150) {
              setState(() {
                isShow = true;
              });
            } else {
              setState(() {
                isShow = false;
              });
            }
          });
          
          return Scaffold(
            bottomNavigationBar:dataService.itemsCart.length>0?Container(
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
                padding: const EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 10),
                child: GestureDetector(
                  onTap:() async {
                    if(cubit.store['is_open']==false){
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
                      if (latitud != null){
                        var totalPrice = await navigateTo(
                            context,CheckoutPage(
                          rout:'grocery',
                          paymentMethods:cubit.store['payment_methods'],
                          service_fee:cubit.store['service_fee'],
                          delivery_price:cubit.store['delivery_price'],
                          olddelivery_price:cubit.store['delivery_price_old'],
                          store:cubit.store,
                        ));
                        setState(() {
                          totalPrice = price;
                        });
                      } else {
                        final changeAdress = await navigateTo(
                            context,
                            SelectAddres(
                              routing: 'restaurantPage',
                              paymentMethods:cubit.store['payment_methods'],
                              service_fee:cubit.store['service_fee'],
                              delivery_price:cubit.store['delivery_price'],
                              olddelivery_price:cubit.store['delivery_price_old'],
                              store:cubit.store,
                            ));
                        setState(() {
                          if (changeAdress != null) {
                            MyLocation = changeAdress;
                          }
                        });
                      }
                    }

                  },

                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red,
                    ),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15),
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
                                      color:dataService.itemsCart.length == 0 ? Color.fromARGB(255, 253, 143, 135) : Color.fromARGB(255, 253, 106, 95),
                                    ),
                                    child: Center(
                                        child: Text(
                                          '${dataService.itemsCart.length}',
                                          textAlign: TextAlign.center,
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
                            ' درهم ${cubit.getTotalPrice()}',
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
            ):height(0),
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 0,
              elevation: 0,
            ),
            body:state is!GetResturantPageDataLoadingState?
            peak_time_status=='full'?Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood,size: 100,color: AppColor),
                  height(20),
                  Text(DemoLocalization.of(context).getTranslatedValue('bienvenue'),style: TextStyle(
                      fontSize:25,
                      fontWeight:FontWeight.w500
                  )),
                  height(20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: Container(
                      child:Text(DemoLocalization.of(context).getTranslatedValue('peack'),style: TextStyle(
                          height: 2.5,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),
            ):CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight:isShow ? 50:0,
                  elevation: 0,
                  expandedHeight: 0,
                  pinned: true,
                  title: Text(
                    isShow ? 'SuperMarketSalam' : '',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  actions: [
                    Stack(
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
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 5),
                          child: GestureDetector(
                            onTap: () async{
                              print('object');
                              if (Platform.isAndroid) {
                                await FlutterShare.share(
                                  title: 'Canari food and More',
                                  text: 'مرحباً ، لقد وجدت هذا المطعم ${cubit.store['name']} في كناري. الطعام يبدو جيدًا! إلق نظرة',
                                  linkUrl: 'https://play.google.com/store/apps/details?id=com.canari.app',
                                );
                              } else if (Platform.isIOS) {
                                await FlutterShare.share(
                                  title: 'Canari food and More',
                                  text: 'مرحباً ، لقد وجدت هذا المطعم ${cubit.store['name']} في كناري. الطعام يبدو جيدًا! إلق نظرة',
                                  linkUrl: 'https://apps.apple.com/ma/app/canari-food-delivery/id6448685108',
                                );
                              }
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
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              service_type = 'food';
                            });
                            Navigator.pop(context,'${cubit.getTotalPrice()}');
                          },
                          child: CircleAvatar(
                              child: Icon(Icons.arrow_back,color: Colors.black, size: 26),
                              backgroundColor: Colors.white,
                              minRadius: 22),
                        ),
                      ),

                    ],
                  ),
                ),
                SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            height: 210,
                            color: Colors.white,
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.topCenter,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 140,
                                        color: Colors.black,
                                        child: Opacity(
                                          opacity: cubit.store['is_open'] == false
                                              ? 0.3
                                              : 1,
                                          child: CachedNetworkImage(
                                              width: double.infinity,
                                              imageUrl:'${cubit.store['cover']}',
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
                                              imageBuilder: (context,imageProvider){
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

                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  setState(() {
                                                    service_type = 'food';
                                                  });
                                                  Navigator.pop(context,'${cubit.getTotalPrice()}');

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
                                                onTap: ()async{
                                                  if (Platform.isAndroid) {
                                                    await FlutterShare.share(
                                                      title: 'Canari food and More',
                                                      text: 'مرحباً ، لقد وجدت هذا المطعم ${cubit.store['name']} في كناري. الطعام يبدو جيدًا! إلق نظرة',
                                                      linkUrl: 'https://play.google.com/store/apps/details?id=com.canari.app',
                                                    );
                                                  } else if (Platform.isIOS) {
                                                    await FlutterShare.share(
                                                      title: 'Canari food and More',
                                                      text: 'مرحباً ، لقد وجدت هذا المطعم ${cubit.store['name']} في كناري. الطعام يبدو جيدًا! إلق نظرة',
                                                      linkUrl: 'https://apps.apple.com/ma/app/canari-food-delivery/id6448685108',
                                                    );
                                                  }
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 30,right: 30),
                                  child: Container(
                                    height: 135,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey[300],
                                          width: 0.9
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    width: 65,
                                                    height: 65,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child:ClipRRect(
                                                      borderRadius: BorderRadius.circular(5),
                                                      child:CachedNetworkImage(
                                                          imageUrl: '${cubit.store['logo']}',
                                                          placeholder: (context, url) =>
                                                              Image.asset('assets/placeholder.png',fit: BoxFit.cover),
                                                          errorWidget: (context, url, error) =>Image.asset('assets/placeholder.png',fit: BoxFit.cover),
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
                                                width(4),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${cubit.store['name']}',style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16
                                                    )),
                                                    Wrap(
                                                      crossAxisAlignment: WrapCrossAlignment.start,
                                                      children: [
                                                        Text('${cubit.store['categories'].map((item) => item['name']).join(' , ')}',style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.grey[400],
                                                        ),)
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),

                                              if(cubit.store['tags'].length>0)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8,right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Color(0xfffafafa),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 4,left: 8,right: 10,bottom: 6),
                                                    child: Text(DemoLocalization.of(context).getTranslatedValue('nouveau'),
                                                      style:TextStyle(
                                                          color:Color(0xffff7144),
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold
                                                      ),),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(DemoLocalization.of(context).getTranslatedValue('Frais_de_livraison'),style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600]
                                                ),),
                                                height(5),
                                                cubit.ispriceLoading? Row(
                                                  children: [
                                                    Text(
                                                        cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                        style: TextStyle(
                                                            fontSize:10.5,
                                                            fontWeight: FontWeight.bold,color: AppColor)
                                                    ),

                                                    if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                                      width(4),
                                                    if(cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']!=cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price'])
                                                      Text(' ${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.store['id']).toList()[0]['delivery_price_old']} درهم ',
                                                          style: TextStyle(
                                                              decoration: TextDecoration.lineThrough,
                                                              fontSize:10.2,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.grey[400]
                                                          )
                                                      )
                                                  ],
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
                                            Container(
                                                height: 30,
                                                width: 1,
                                                color:Colors.grey[300]
                                            ),
                                            Column(
                                              children: [
                                                Text(DemoLocalization.of(context).getTranslatedValue('status_stores'),style: TextStyle(
                                                    fontSize: 11,
                                                    color:Colors.grey[600]
                                                ),),
                                                height(5),
                                                Text(cubit.store['is_open'] != false?DemoLocalization.of(context).getTranslatedValue('ouvrir'):DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                ),)
                                              ],
                                            ),
                                            Container(
                                                height: 30,
                                                width: 1,
                                                color:Colors.grey[300]
                                            ),
                                            GestureDetector(
                                                child: Column(
                                                  children: [
                                                    Icon(Icons.info,size:14,color:Colors.grey[400]),
                                                    height(5),
                                                    Text(DemoLocalization.of(context).getTranslatedValue('plus_de_détails'),style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),)
                                                  ],
                                                ),
                                                onTap:(){
                                                  showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      context: context, builder:(context){
                                                    return restaurantInfo(cubit:cubit);
                                                  } );
                                                }
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                SliverToBoxAdapter(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20,top: 20,bottom: 10,left:20),
                  child: Text(DemoLocalization.of(context).getTranslatedValue('Categorie'),style: TextStyle(
                      fontSize:16,color:Colors.black,fontWeight: FontWeight.bold
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:20,right:20,top: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1/1.46
                    ),
                    itemCount:cubit.store['menus'].length,
                    itemBuilder: (ctx, index) {
                      StoreName = cubit.store['name'];
                      StoreId = cubit.store['id'];
                      deliveryPrice =cubit.store['delivery_price'];
                      storeStatus = cubit.store['is_open'];
                      cubit.qty = 1;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap:()async{
                              var totalPrice = await navigateTo(context,MarketDetails(menus:cubit.store['menus'][index],store:cubit.store));
                              setState((){
                                price = totalPrice;
                              });
                              print(totalPrice);
                              },
                            child: Container(
                                height:90,
                                width:90,
                                decoration: BoxDecoration(
                                  color:Color(0xfffff4f4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:cubit.store['menus'][index]['image']!=''?Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                      imageUrl: '${cubit.store['menus'][index]['image']}',
                                      placeholder: (context, url) =>
                                      Image.asset('assets/placeholder.png',fit: BoxFit.cover),
                                      errorWidget: (context, url, error) =>Image.asset('assets/placeholder.png',fit: BoxFit.cover),
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
                                )
                                    :ClipRRect(
                                  child: Image.asset('assets/placeholder.png'),
                                  borderRadius:BorderRadius.circular(7),
                                )
                            ),
                          ),
                          height(9),
                          Text('${cubit.store['menus'][index]['name']}',textAlign: TextAlign.center,style: TextStyle(
                            fontSize: 13,
                          ),),

                        ],
                      );
                    },
                  ),
                ),
                

                
                Padding(
                  padding: const EdgeInsets.only(right: 20,top: 10,bottom: 10,left:20),
                  child: Text(DemoLocalization.of(context).getTranslatedValue('Best_seller'),style: TextStyle(
                      fontSize:16,color:Colors.black,fontWeight: FontWeight.bold
                  )),
                ),

                BuildCondition(
                  condition:true,
                  builder: (context){
                    return Padding(
                      padding: const EdgeInsets.only(left:20,right:20),
                      child:cubit.store['group_products'].length>0?Container(
                        height: 280,
                        color: Colors.white,
                        child:ListView.builder(
                            scrollDirection:Axis.horizontal,
                            itemCount:cubit.store['group_products'].length,
                            shrinkWrap:true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index){
                              var product = cubit.store['group_products'][index];
                              var contain = dataService.itemsCart.where((element) =>
                              element['id'] == product['id']).toList();
                              if (contain.isEmpty){
                                isExited = false;
                              }else{
                                isExited = true;
                              }

                              return Container(
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  children:[
                                    InkWell(
                                      onTap: () async {
                                        if(product['modifierGroups']==null){
                                          var totalPrice = await showModalBottomSheet(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                              ),
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
                                    // height(5),
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
                                        height:40,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            TextButton(
                                              onPressed: (){
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
                                            width(5),
                                            Text('${contain[0]['quantity']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                                            width(5),
                                            contain[0]['quantity']==1?TextButton(onPressed: (){
                                              setState(() {
                                                dataService.itemsCart.removeWhere((element) => element['id']==product['id']);
                                              });
                                            },child:Icon(Icons.delete,color: Colors.red,size: 22)):TextButton(onPressed: (){
                                              removeFromCart(id:product['id']);
                                            },child:Icon(Icons.remove,color: Colors.red,size: 22)),
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
                                              scrollController.jumpTo(55);
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
                                        alignment: Alignment.bottomRight,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ):height(0),
                    );
                  },
                  fallback: (context){
                    return Padding(
                      padding:EdgeInsets.only(left: 0,right: 15,bottom: 0,top: 5),
                      child: Container(
                        height: 220,
                        color: Colors.white,
                        child:
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return width(10);
                          },
                          physics: BouncingScrollPhysics(),
                          itemCount:7,
                          shrinkWrap: true,
                          scrollDirection:Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap:(){},
                              child:
                              Container(
                                decoration:BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 230,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(alignment: Alignment.topLeft,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            period: Duration(seconds: 2),
                                            highlightColor: Colors.grey[100],
                                            child: Container(
                                              decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              height: 125,
                                              width: 259,

                                            ),
                                          ),
                                        ]),
                                    height(5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            'Motlen Chocolate',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    height(5),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, bottom: 0),
                                          child:Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            period: Duration(seconds: 2),
                                            highlightColor: Colors.grey[100],
                                            child:Container(
                                              decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                'Sandawiches  italian Fast Food',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0A8791),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    height(4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: Row(children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                    size: 16,
                                                  ),
                                                  width(5),
                                                  Text(
                                                    "",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  width(5),
                                                  Text(
                                                    "Excellent",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ]),
                                              ),
                                              width(5),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 10,
                                                    width: 1,
                                                    color: Colors.black,
                                                  ),
                                                  width(5),
                                                  Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.brown[900],
                                                        fontWeight: FontWeight.w600),
                                                  )
                                                ],
                                              )

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                restaurantsWithDiscount.length>0? Padding(
                  padding: const EdgeInsets.only(right: 20,left:20,top: 10),
                  child: Text(DemoLocalization.of(context).getTranslatedValue('Meilleures_offres'),style: TextStyle(
                      fontSize:16,color:Colors.black,fontWeight: FontWeight.bold
                  )),
                ):height(0),
                BuildCondition(
                  condition:true,
                  builder: (context){
                    return Padding(
                      padding: const EdgeInsets.only(left: 5, right: 0),
                      child:restaurantsWithDiscount.length>0?Container(
                        height: 250,
                        color: Colors.white,
                        child:ListView.builder(
                            scrollDirection:Axis.horizontal,
                            itemCount:restaurantsWithDiscount.length,
                            shrinkWrap:true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index){
                              var product = restaurantsWithDiscount[index];
                              var contain = dataService.itemsCart.where((element) =>
                              element['id'] == product['id']).toList();
                              if (contain.isEmpty){
                                isExited = false;
                              }else{
                                isExited = true;
                              }

                              return
                                Padding(
                                  padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom:10),
                                  child: Container(
                                    color: Colors.white,
                                    child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      children:[
                                        InkWell(
                                          onTap:()async{
                                            var totalPrice = await showModalBottomSheet(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                                ),
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
                                              },
                                          child: Container(
                                            child:product['image']!=''?ClipRRect(
                                                borderRadius:BorderRadius.circular(7),
                                                child:Image.network('${product['image']}',fit: BoxFit.cover,))
                                                :ClipRRect(
                                                borderRadius:BorderRadius.circular(7),
                                                child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
                                            height: 150,
                                            width: 150,
                                          ),
                                        ),
                                        Text('${product['name']}',style: TextStyle(
                                            fontWeight: FontWeight.bold,fontSize: 13.5,
                                            overflow: TextOverflow.ellipsis
                                        ),maxLines: 2,textAlign: TextAlign.center,
                                        ),
                                        height(5),
                                        Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} '),
                                        // height(5),
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
                                                width(5),
                                                Text('${contain[0]['quantity']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                                                width(5),
                                                contain[0]['quantity']==1?TextButton(onPressed: (){
                                                  setState(() {
                                                    dataService.itemsCart.removeWhere((element) => element['id']==product['id']);
                                                  });
                                                },child:Icon(Icons.delete,color: Colors.red,size: 22)):TextButton(onPressed: (){
                                                  removeFromCart(id:product['id']);
                                                },child:Icon(Icons.remove,color: Colors.red,size: 22)),
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
                                            alignment: Alignment.bottomRight,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                            }),
                      ):height(0),
                    );
                  },
                  fallback: (context){
                    return Padding(
                      padding:EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 5,),
                      child: Container(
                        height: 220,
                        color: Colors.white,
                        child:
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return width(10);
                          },
                          physics: BouncingScrollPhysics(),
                          itemCount:7,
                          shrinkWrap: true,
                          scrollDirection:Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap:(){},
                              child:
                              Container(
                                decoration:BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 230,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(alignment: Alignment.topLeft,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            period: Duration(seconds: 2),
                                            highlightColor: Colors.grey[100],
                                            child: Container(
                                              decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              height: 125,
                                              width: 259,

                                            ),
                                          ),
                                        ]),
                                    height(5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            'Motlen Chocolate',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    height(5),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, bottom: 0),
                                          child:Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            period: Duration(seconds: 2),
                                            highlightColor: Colors.grey[100],
                                            child:Container(
                                              decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                'Sandawiches  italian Fast Food',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0A8791),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    height(4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: Row(children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                    size: 16,
                                                  ),
                                                  width(5),
                                                  Text(
                                                    "",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  width(5),
                                                  Text(
                                                    "Excellent",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ]),
                                              ),
                                              width(5),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 10,
                                                    width: 1,
                                                    color: Colors.black,
                                                  ),
                                                  width(5),
                                                  Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.brown[900],
                                                        fontWeight: FontWeight.w600),
                                                  )
                                                ],
                                              )

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                ListView.builder(
                  physics:NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:cubit.store['menus'].length,
                  itemBuilder:(context,index){
                 return cubit.store['menus'][index]['products'].length>=4?Padding(
                   padding: const EdgeInsets.only(right: 20,top: 0,bottom: 0,left: 20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[
                        Text('${cubit.store['menus'][index]['name']}',style: TextStyle(
                          fontSize:16,color:Colors.black,fontWeight: FontWeight.bold
                          )),

                        BuildCondition(
                          condition:true,
                          builder: (context){
                            return Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0,top:5),
                              child:cubit.store['menus'][index]['products'].length>0?Container(
                                height: 280,
                                color: Colors.white,
                                child:ListView.builder(
                                    scrollDirection:Axis.horizontal,
                                    itemCount:cubit.store['menus'][index]['products'].length,
                                    shrinkWrap:true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, productIndex){
                                      var product = cubit.store['menus'][index]['products'][productIndex];
                                      var contain = dataService.itemsCart.where((element) =>
                                      element['id'] == product['id']).toList();
                                      if (contain.isEmpty){
                                        isExited = false;
                                      }else{
                                        isExited = true;
                                      }

                                      return Container(
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children:[
                                            InkWell(
                                              onTap: () async {
                                                if(product['modifierGroups'].length==0){
                                                  var totalPrice = await showModalBottomSheet(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                                      ),
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
                                            // height(5),
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
                                                height:40,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children:[
                                                    TextButton(
                                                      onPressed: (){
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
                                                    width(5),
                                                    Text('${contain[0]['quantity']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                                                    width(5),
                                                    contain[0]['quantity']==1?TextButton(onPressed: (){
                                                      setState(() {
                                                        dataService.itemsCart.removeWhere((element) => element['id']==product['id']);
                                                      });
                                                    },child:Icon(Icons.delete,color: Colors.red,size: 22)):TextButton(onPressed: (){
                                                      removeFromCart(id:product['id']);
                                                    },child:Icon(Icons.remove,color: Colors.red,size: 22)),
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
                                                      scrollController.jumpTo(55);
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
                                                alignment: Alignment.bottomRight,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ):height(0),
                            );
                          },
                          fallback: (context){
                            return Padding(
                              padding:EdgeInsets.only(left: 0,right: 15,bottom: 0,top: 5),
                              child: Container(
                                height: 220,
                                color: Colors.white,
                                child:
                                ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return width(10);
                                  },
                                  physics: BouncingScrollPhysics(),
                                  itemCount:7,
                                  shrinkWrap: true,
                                  scrollDirection:Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap:(){},
                                      child:
                                      Container(
                                        decoration:BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width: 230,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(alignment: Alignment.topLeft,
                                                children: [
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey[300],
                                                    period: Duration(seconds: 2),
                                                    highlightColor: Colors.grey[100],
                                                    child: Container(
                                                      decoration:BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      height: 125,
                                                      width: 259,

                                                    ),
                                                  ),
                                                ]),
                                            height(5),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    'Motlen Chocolate',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13.5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            height(5),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5, bottom: 0),
                                                  child:Shimmer.fromColors(
                                                    baseColor: Colors.grey[300],
                                                    period: Duration(seconds: 2),
                                                    highlightColor: Colors.grey[100],
                                                    child:Container(
                                                      decoration:BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Text(
                                                        'Sandawiches  italian Fast Food',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF0A8791),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            height(4),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300],
                                                period: Duration(seconds: 2),
                                                highlightColor: Colors.grey[100],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 4),
                                                        child: Row(children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.yellow,
                                                            size: 16,
                                                          ),
                                                          width(5),
                                                          Text(
                                                            "",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                          width(5),
                                                          Text(
                                                            "Excellent",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ]),
                                                      ),
                                                      width(5),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            height: 10,
                                                            width: 1,
                                                            color: Colors.black,
                                                          ),
                                                          width(5),
                                                          Text(
                                                            '',
                                                            style: TextStyle(
                                                                color: Colors.brown[900],
                                                                fontWeight: FontWeight.w600),
                                                          )
                                                        ],
                                                      )

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                   ),
                 ):height(0);
                },

                  )


              ],
            )
          ),



              ],
               )
                :SingleChildScrollView(
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                  ),
                  height(15),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            height: 15,
                            width: 90,
                            color: Colors.grey,
                            child: Text(
                              '',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF000000),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            height: 15,
                            width: 60,
                            color: Colors.grey,
                            child: Text(
                              '',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF000000),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(5),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child:Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        height: 13,
                        width: 40,
                        color: Colors.grey,
                        child: Text(
                          '',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF000000),
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  height(10),
                  Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height: 10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:80,
                                width:80,
                                decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(7)),
                              ),
                            ),
                            height(5),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height:10,
                                width: 80,
                                color: Colors.grey,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF000000),
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height(15),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,top:20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            height: 15,
                            width: 90,
                            color: Colors.grey,
                            child: Text(
                              '',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF000000),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            height: 15,
                            width: 60,
                            color: Colors.grey,
                            child: Text(
                              '',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF000000),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(10),
                  Container(
                    height:230,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) { 
                         return Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Column(
                             children: [
                               Shimmer.fromColors(
                                 baseColor: Colors.grey[300],
                                 highlightColor: Colors.grey[100],
                                 child: Container(
                                   height:180,
                                   width:140,
                                   decoration: BoxDecoration(
                                     color: Colors.grey,
                                     borderRadius: BorderRadius.circular(8)
                                   ),
                                 ),
                               ),
                               height(10),
                               Padding(
                                 padding: const EdgeInsets.only(left: 10,right: 10),
                                 child:Shimmer.fromColors(
                                   baseColor: Colors.grey[300],
                                   highlightColor: Colors.grey[100],
                                   child: Container(
                                     height: 5,
                                     width: 100,
                                     color: Colors.grey,
                                     child: Text(
                                       '',
                                       style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           color: Color(0xFF000000),
                                           fontSize: 15),
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         );
                    },
                      shrinkWrap:true,
                      scrollDirection:Axis.horizontal,
                    ),
                     
                      width:double.infinity
                  )
              ],
            ),
                ),
          );
        },
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
    return Column(
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
                child:CachedNetworkImage(
                    height: 250,
                    width: double.infinity,
                    imageUrl: '${cubit.store['cover']}',
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
                          imageUrl: '${cubit.store['logo']}',
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
                          '${cubit.store['name']}',
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
                          Text('${cubit.store['categories'].map((item) => item['name']).join(' , ')}',style: const TextStyle(
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
              cubit.store['rate']<=2?
              infoItem(icon: Icons.emoji_emotions_outlined,infotitel:DemoLocalization.of(context).getTranslatedValue('normale'),InfoDescript: '${cubit.store['rate']} ${DemoLocalization.of(context).getTranslatedValue('Évaluation')} '):infoItem(icon: Icons.emoji_emotions_outlined,infotitel:cubit.store['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),InfoDescript: '${cubit.store['rate']} ${DemoLocalization.of(context).getTranslatedValue('Évaluation')} '),
              height(15),
              Container(height: 0.1,width:double.infinity ,color: Colors.black,),
              height(15),
              payment_by_card? infoItem(icon: Icons.account_balance_wallet_outlined,infotitel: DemoLocalization.of(context).getTranslatedValue('Mode_de_paiement'),InfoDescript:cubit.store['payment_methods'].length!=2? cubit.store['payment_methods'].contains('CASH')?DemoLocalization.of(context).getTranslatedValue('Payer_en_cash'):DemoLocalization.of(context).getTranslatedValue('Payer_par_carte'):DemoLocalization.of(context).getTranslatedValue('Payer_par_Carte_ou_en_Cash')):infoItem(icon: Icons.account_balance_wallet_outlined,infotitel:DemoLocalization.of(context).getTranslatedValue('Mode_de_paiement'),InfoDescript:DemoLocalization.of(context).getTranslatedValue('Payer_en_cash')),
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

  Widget buildProduct(product,cubit,StoreName,StoreId,deliveryPrice,storeStatus,{double calculatePrice,offers}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            calculatePrice!=null? Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color:Colors.grey[400],decoration: TextDecoration.lineThrough),),
            ):height(0),
            Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${calculatePrice==null?product['price']:calculatePrice} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
            ),

          ],
        ),

        height(20),
        StatefulBuilder(builder: (context,setState){
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            height: 75,
            child: Padding(
              padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 10),
              child: GestureDetector(
                onTap: (){
                  StoreId = StoreId;
                  deliveryPrice = deliveryPrice;
                  cubit.addToCart(
                      product:product,
                      Qty:cubit.qty,
                      productStoreId:StoreId,
                      attributes:[],
                      storeStats: storeStatus,
                      offers:offers,
                      storeName:StoreName

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
                        offers:offers
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
                        height:50,
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
                                  if(cubit.qty > 1){
                                    cubit.qty =cubit.qty-1;
                                  }
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
                                  cubit.qty = cubit.qty+1;
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


