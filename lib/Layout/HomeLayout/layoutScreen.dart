import 'dart:collection';
import 'package:buildcondition/buildcondition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/HomeLayout/home.dart';
import 'package:shopapp/Layout/HomeLayout/account.dart';
import 'package:shopapp/Layout/HomeLayout/selectAddres.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../LayoutMarket/MarketPages/layout_market.dart';
import '../../localization/demo_localization.dart';
import '../../modules/pages/Static/share.dart';
import '../../modules/pages/StorePage/store_page.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/remote/cachehelper.dart';
import '../shopcubit/storecubit.dart';
import '../shopcubit/storestate.dart';
import 'searchStore.dart';

class LayoutScreen extends StatefulWidget {
  final String myLocation;
  final double latitude;
  final double longitude;
  const LayoutScreen({Key key, this.myLocation, this.latitude, this.longitude}) : super(key: key);

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  var price;
  String MyLocation = Cachehelper.getData(key: "myLocation");
  HashSet selectFilters = new HashSet();
  bool isServicesLoading = true;

  List services = [];
  int SelectedIndex = 0;
  Future<void> GetServices() async{
    setState(() {
      isServicesLoading = false;
    });
    http.Response response = await http.get(Uri.parse('https://api.canariapp.com/v1/client/services?locale=$lg'),
    ).then((value){
      var responsebody = jsonDecode(value.body);
      printFullText(responsebody.toString());
      setState(() {
        isServicesLoading = true;
        print(responsebody.length);
        services = responsebody;

      });
    }).catchError((onError){

    });
    return response;
  }

  List FakeServices = [{
    "image":"https://images.deliveryhero.io/image/fd-my/LH/cr42-listing.jpg"
  },{
    "image":"https://images.deliveryhero.io/image/talabat/launcher/grocery.png?v=2"
  },{
    "image":"https://images.deliveryhero.io/image/fd-my/LH/uu3x-listing.jpg"
  },{
    "image":"https://images.deliveryhero.io/image/talabat/launcher/pharmacy.png?v=2"
  },];

  List Offers = [{
    "image":"https://images.deliveryhero.io/image/fd-my/LH/cr42-listing.jpg"
  },{
    "image":"https://images.deliveryhero.io/image/talabat/launcher/grocery.png?v=2"
  },{
    "image":"https://images.deliveryhero.io/image/fd-my/LH/uu3x-listing.jpg"
  },{
"image":"https://images.deliveryhero.io/image/talabat/launcher/pharmacy.png?v=2"
}];
  @override
  void initState() {
    GetServices();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StoreCubit()..getStoresPopular(latitude: latitud==null?27.149890:latitud,longitude: longitud==null?-13.199970:longitud),
      child: BlocConsumer<StoreCubit, ShopStates>(
        listener: (context,state){},
        builder: (context,state){
          var cubit = StoreCubit.get(context);
          return Scaffold(
            backgroundColor:Colors.white,
            body:CustomScrollView(
              slivers:[
                SliverAppBar(
                  backgroundColor:Color(0xfffef4f3),
                  automaticallyImplyLeading: false,
                  toolbarHeight:65,
                  elevation:0,
                  pinned: true,
                  title: GestureDetector(
                     onTap:(){
                       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>SelectAddres(routing: 'homelayout',)),(route) => false);
                     },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyLocation!=null?Expanded(
                          child: Row(
                            children:[
                              Icon(Icons.location_on,color: Colors.black),
                              MyLocation.length<=30?Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.red,),),
                                    height(4),
                                    Text(
                                      MyLocation!=null? "${MyLocation}":DemoLocalization.of(context).getTranslatedValue('Choisissez_un_emplacement'),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ):
                              Expanded(
                                child:Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:12,color: Colors.red,fontWeight: FontWeight.bold),),
                                      Text(
                                        MyLocation!=null?"${MyLocation}":DemoLocalization.of(context).getTranslatedValue('Choisissez_un_emplacement'),
                                        textAlign:TextAlign.start,
                                        overflow:TextOverflow.ellipsis,
                                        maxLines:1,
                                        textDirection:TextDirection.ltr,
                                        style:TextStyle(
                                            color:Colors.black,
                                            fontWeight:FontWeight.bold,
                                            fontSize:12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ):
                        Expanded(
                          child: Row(
                            children:[
                              Icon(Icons.location_on,color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.red,),),
                                    height(4),
                                    Text(
                                      MyLocation!=null? "${MyLocation}":DemoLocalization.of(context).getTranslatedValue('Choisissez_un_emplacement'),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                    actions:[
                     Row(
                       children: [
                         lg!='ar'?Padding(
                           padding:EdgeInsets.only(left:10,right:10),
                           child:Center(
                             child:IconButton(onPressed:(){
                               navigateTo(context,Account(routing: 'homelayout',));
                             },
                                 icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                           ),
                         ):Padding(
                           padding:EdgeInsets.only(left:15,right:0),
                           child:Center(
                             child:IconButton(onPressed:(){
                               navigateTo(context,Account(routing:'homelayout',));
                             },
                                 icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                           ),
                         ),

                       ],
                     )
                    ],
                ),

                SliverPadding(
                  sliver: SliverToBoxAdapter(
                    child:Column(
                      children: [
                      Container(
                        color:Color(0xfffff4f4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25,right: 20,bottom: 20),
                              child: GestureDetector(
                              onTap: (){
                               navigateTo(context, SearchStore());
                                },
                               child:Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:Colors.white,
                                ),
                                height:40,
                                width:double.infinity,
                                child:Row(
                                  children:[
                                    SizedBox(width: 15,),
                                    Icon(Icons.search,color: Color.fromARGB(255,98,98,98),size: 20),
                                    width(5),
                                    Text(DemoLocalization.of(context).getTranslatedValue('search_bymeal'),style: TextStyle(
                                        color: Color.fromARGB(255, 98, 98, 98),
                                        fontSize: 13
                                    )),
                                  ],
                                ),
                              ),
                               ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25,right: 25,bottom: 5),
                                  child: Text(DemoLocalization.of(context).getTranslatedValue('welcome'),style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,fontSize: 25
                                  ),),
                                ),
                                lg!='ar'?Padding(
                                  padding: const EdgeInsets.only(left: 25,right: 50,bottom: 20),
                                  child: Text(DemoLocalization.of(context).getTranslatedValue('welcome_description'),style: TextStyle(
                                    fontSize: 14,color: Colors.blueGrey,
                                    fontWeight: FontWeight.w300,
                                    height: 1.5
                                  ),),
                                ):Padding(
                                  padding: const EdgeInsets.only(left: 50,right: 25,bottom: 20),
                                  child: Text(DemoLocalization.of(context).getTranslatedValue('welcome_description'),style: TextStyle(
                                      fontSize: 14,color: Colors.blueGrey,
                                      fontWeight: FontWeight.w300,
                                      height: 1.5
                                  ),),
                                )
                              ],
                            ),
                            height(10),
                          ],
                        ),
                  ),

                      ],
                    ),
                  ), padding: const EdgeInsets.symmetric(horizontal: 0),
                ),

                SliverPadding(
                  padding: EdgeInsets.only(top: 20),
                  sliver:SliverToBoxAdapter(
                    child:Stack(
                      children:[
                        isServicesLoading?
                        Center(
                          child: Wrap(
                            runSpacing:15,
                            spacing:15,
                            children:[
                              ...services.map((e) =>Column(
                                children:[
                                  Stack(
                                    children: [
                                      Stack(
                                        alignment: Alignment.topLeft,
                                        children:[
                                          GestureDetector(
                                            onTap: (){
                                              print(e['service_id']);
                                              setState(() {
                                                peak_time_status = e['peak_time_status'];
                                                service_type = e['service_id'];
                                              });
                                              if(e['status']=='published'){
                                                if(e['service_id']=="grocery"){
                                                  // setState(() {
                                                  //   // grocery_market_id = e['grocery_market_id'];
                                                  //   print(e);
                                                  // });
                                                  navigateTo(context,LayoutMarket());
                                                }else{
                                                  service_type = e['service_id'];
                                                  navigateTo(context,Home(
                                                    myLocation:widget.myLocation,
                                                    longitude:widget.longitude,
                                                    latitude:widget.latitude,
                                                    category:service_type,
                                                  ));
                                                }
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),color:Color(0xfff9fafb),),
                                              child:ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child:Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: CachedNetworkImage(
                                                      height:90,
                                                      width:90,
                                                      imageUrl:"${e['image']}",
                                                      placeholder: (context, url) =>
                                                          Image.asset('assets/placeholder.png',fit:BoxFit.cover,),
                                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                                      imageBuilder: (context, imageProvider){
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: imageProvider,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          e['status']=='published'?height(0):Padding(
                                            padding: const EdgeInsets.only(right: 5,top:7,left:5),
                                            child:Icon(Icons.lock_rounded,size: 20,),
                                          )
                                        ],
                                      ),
                                      e['description']!=null?Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child:Container(
                                            height:25,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child:Padding(
                                              padding: const EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 0),
                                              child: Text('${e['description']}',style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold
                                              )),
                                            )
                                        ),
                                      ):height(0)
                                    ],
                                    alignment: Alignment.topCenter,
                                  ),
                                  height(10),
                                  Text(
                                    '${e['name']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000000),
                                        fontSize: 15),
                                  ),
                                ],
                              ))
                            ],
                          ),
                        )
                        :Center(
                          child:Padding(
                            padding: const EdgeInsets.only(left: 0,right: 0,top: 10),
                            child: Wrap(
                              runSpacing: 15,
                              spacing: 15,
                              children:[
                                ...FakeServices.map((e) => Column(
                                  children:[
                                    Stack(
                                      children: [
                                        Stack(
                                          alignment: Alignment.topLeft,
                                          children:[
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey[200],
                                              period: Duration(seconds: 2),
                                              highlightColor: Colors.grey[100],
                                              child: Container(
                                                decoration:BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                height: 110,
                                                width: 110,
                                              ),
                                            ),
                                          ],

                                        ),

                                      ],
                                    ),
                                    height(10),
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[200],
                                      highlightColor: Colors.grey[100],
                                      child: Container(
                                        height:5,
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
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                    child:Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20,left: 10,top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lg=='ar'?"الأكثر شعبية":"le plus populaire",
                                  style: TextStyle(
                                    color:Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                GestureDetector(onTap: (){
                                  setState(() {
                                    service_type = 'food';
                                  });
                                  navigateTo(context,Home(
                                    myLocation:widget.myLocation,
                                    longitude:widget.longitude,
                                    latitude:widget.latitude,
                                    category:service_type,
                                  ));
                                }, child: Text(lg=='ar'?"رؤية المزيد":'voir plus',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppColor
                                ),))
                              ],
                            ),
                          ),
                          height(15),
                          BuildCondition(
                            condition:cubit.isNearStoresLoading,
                            builder: (context){
                              // final newStores =  cubit.stores.where((store) => store['tags'].contains('new')).toList();
                              return Padding(
                                padding: const EdgeInsets.only(left: 15, right: 5),
                                child: cubit.storesNear.length>0?Container(
                                  height: 190,
                                  color: Colors.white,
                                  child:ListView.builder(
                                      scrollDirection:Axis.horizontal,
                                      itemCount:cubit.storesNear.length,
                                      shrinkWrap:true,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index){
                                        var categories = cubit.storesNear[index]['categories'].length >= 3 ? cubit.storesNear[index]['categories'].sublist(0, 3) : cubit.storesNear[index]['categories'];
                                        var offers = cubit.storesNear[index]['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder'&& e['type'] != 'freeDelivery').toList();
                                        return Padding(
                                          padding:EdgeInsets.only(left: 0,right: 10,bottom: 0),
                                          child: InkWell(
                                            onTap: ()async{
                                              var totalPrice = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) =>StorePage(
                                                      paymentMethods:cubit.storesNear[index]['payment_methods'],
                                                      name:cubit.storesNear[index]['name'],
                                                      cover:cubit.storesNear[index]['cover'],
                                                      price_delivery:cubit.storesNear[index]['delivery_price'],
                                                      oldprice_delivery:cubit.storesNear[index]['delivery_price_old'],
                                                      rate:cubit.storesNear[index]['rate'],
                                                      deliveryTime:cubit.storesNear[index]['delivery_time'],
                                                      cuisines: categories,
                                                      id:cubit.storesNear[index]['id'],
                                                      slug:cubit.storesNear[index]['slug'],
                                                      brandlogo:cubit.storesNear[index]['logo'],
                                                      tags:cubit.storesNear[index]['tags'],
                                                      service_fee:cubit.storesNear[index]['service_fee']
                                                  )
                                                  )
                                              );
                                              setState(() {
                                                totalPrice = price;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              width: 280,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Stack(alignment:lg!='ar'?Alignment.topLeft:Alignment.topRight,
                                                      children:[
                                                        Container(
                                                          height: 125,
                                                          width: double.infinity,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child:ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child:
                                                            Container(
                                                              color:cubit.storesNear[index]['is_open']==false?Colors.grey[200]:Color(0xffeef2f5),
                                                              child: Opacity(
                                                                opacity:cubit.storesNear[index]['is_open']==false?0.5:1,
                                                                child: CachedNetworkImage(
                                                                    height: 250,
                                                                    width: double.infinity,
                                                                    imageUrl: '${cubit.storesNear[index]['cover']}',
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
                                                        ),
                                                        cubit.storesNear[index]['is_open']==false?
                                                        Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 52),
                                                            child: Container(
                                                                width: 78,
                                                                height: 30,
                                                                decoration:BoxDecoration(
                                                                    color:Color(0xFF383737),
                                                                    borderRadius: BorderRadius.circular(17)
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Text(DemoLocalization.of(context).getTranslatedValue('fermé'),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 11.5)),
                                                                    width(3),
                                                                    Icon(Icons.lock,color: Colors.white,size: 14),
                                                                  ],
                                                                )),
                                                          ),
                                                        ):height(0),
                                                        if(cubit.storesNear[index]['delivery_time']!=null)
                                                          Align(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 110,left: 10,right: 10),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.grey[200],
                                                                          spreadRadius: 1,
                                                                          blurRadius: 2,
                                                                          offset: Offset(1, 2)
                                                                      )
                                                                    ],
                                                                    borderRadius: BorderRadius.circular(30),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(6.0),
                                                                    child: Text(' ${cubit.storesNear[index]['delivery_time']} ${DemoLocalization.of(context).getTranslatedValue('Second')} ',style: TextStyle(fontSize: 12.4,color: Colors.black,fontWeight: FontWeight.bold,),textAlign:TextAlign.center),
                                                                  )),
                                                            ),
                                                            alignment:lg!='ar'?Alignment.topRight:Alignment.topLeft,
                                                          ),

                                                        if(cubit.storesNear[index]['tags'].length>0)
                                                          offers.length>0?height(0):Padding(
                                                            padding: const EdgeInsets.only(top: 10,right: 10),
                                                            child: Align(
                                                              alignment: Alignment.topLeft,
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Color(0xfffafafa),
                                                                ),

                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                                                  child: Text(DemoLocalization.of(context).getTranslatedValue('nouveau'),
                                                                    style:TextStyle(
                                                                        color:Color(0xffff7144),
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.bold
                                                                    ),),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if(offers.length>0)
                                                          ...offers.map((e){
                                                            return Align(
                                                              alignment:Alignment.topRight,
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(top: 15,right: 15,left: 15),
                                                                child: Column(
                                                                  children:[
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        color: Color(0xfffafafa),
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(top: 4,left: 8,right: 8,bottom: 6),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Image.asset('assets/discount.png',height: 20),
                                                                            width(2),
                                                                            Text('${e['name']}',
                                                                              style:TextStyle(
                                                                                color:Color(0xffff7144),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),),
                                                                          ],
                                                                        ),
                                                                      ),

                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                      ]),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 40,width: 40,decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                        child:ClipRRect(
                                                            borderRadius: BorderRadius.circular(50),
                                                            child:Image.network('${cubit.storesNear[index]['logo']}',fit:BoxFit.cover)),
                                                      ),
                                                      Padding(
                                                        padding:EdgeInsets.only(left:5,right: 5,top:cubit.storesNear[index]['delivery_time']==null?9:0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '${cubit.storesNear[index]['name']}',
                                                                  style:TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Color(0xFF000000),
                                                                      fontSize: 14.5),
                                                                ),
                                                              ],
                                                            ),
                                                            height(6),
                                                            cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).toList().length>0?Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Icon(Icons.star,color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey[300],size:14),
                                                                width(5),
                                                                Text('${cubit.storesNear[index]['rate'].toStringAsFixed(1)}',style: TextStyle(
                                                                    color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 12
                                                                ),),
                                                                width(5),
                                                                cubit.storesNear[index]['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                                                                    color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w500
                                                                ),):Text(cubit.storesNear[index]['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                                                                    color:cubit.storesNear[index]['rate']>=3.5?Colors.green:Colors.grey,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500
                                                                ),),
                                                                width(5),
                                                                Rate(cubit.storesNear[index]['reviews_count'],cubit.storesNear[index]),
                                                                cubit.storesNear[index]['reviews_count']<10?width(0):width(5),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top:5),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 5,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[300],
                                                                        shape: BoxShape.circle
                                                                    ),),
                                                                ),
                                                                width(4),
                                                                Icon(Icons.delivery_dining_outlined,color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                                                                width(5),
                                                                Text(
                                                                    cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?'${cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                                    style: TextStyle(
                                                                        fontSize:10,
                                                                        color:cubit.PriceDeliverys.where((item)=>item['store_id']==cubit.storesNear[index]['id']).first['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
                                                                        fontWeight: FontWeight.w400)
                                                                ),
                                                              ],
                                                            ):Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SpinKitThreeBounce(
                                                                  color: Colors.grey[400],
                                                                  size: 20.0,
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ):height(0),
                              );
                            },
                            fallback: (context){
                              return Padding(
                                padding:EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 5),
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
                    )
                ),
               !share_app?SliverToBoxAdapter(
                 child:height(0),
               ):SliverPadding(padding: EdgeInsets.only(top:20,left:25,right:25),sliver:SliverToBoxAdapter(
                  child:Container(
                    height:150,
                    width:double.infinity,
                    decoration:BoxDecoration(
                        color:AppColor,
                        borderRadius:BorderRadius.circular(8)
                    ),
                    child:Padding(
                      padding: const EdgeInsets.only(right:10,left:10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                          Expanded(
                            flex:1,
                            child:Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                               Text(DemoLocalization.of(context).getTranslatedValue('share_title'),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
                               height(10),
                               Text(DemoLocalization.of(context).getTranslatedValue('share_and_earn_title'),style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.grey[200],height: 1.2)),
                               height(10),
                               GestureDetector(
                                 onTap:(){
                                   navigateTo(context,Share());
                                 },
                                 child: Container(
                                   decoration:BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(7)
                                   ),
                                   child:Padding(
                                     padding:const EdgeInsets.all(8.0),
                                     child: Text(DemoLocalization.of(context).getTranslatedValue('share_and_earn'),style:TextStyle(
                                       fontWeight: FontWeight.bold,
                                       color:AppColor,
                                       fontSize: 12
                                     )),
                                   ),
                                 ),
                               ),
                            ]),
                          ),
                          Image.asset('assets/send.png',width:100,height:100)
                        ],
                      ),
                    ),
                  ),
                 )),

              ],
            )
          );
        },
      ),
    );
  }
}
