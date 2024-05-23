import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Layout/HomeLayout/account.dart';
import '../../../Layout/HomeLayout/searchStore.dart';
import '../../../Layout/HomeLayout/selectAddres.dart';
import '../../../localization/demo_localization.dart';
import '../../../shared/components/components.dart';
import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';
import 'package:http/http.dart' as http;

import '../StorePage/store_page.dart';

class Offer extends StatefulWidget {
  var text;
  var id;
  Offer({Key key,this.text,this.id}) : super(key: key);
  @override
  State<Offer> createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  String access_token = Cachehelper.getData(key: "token");
  String MyLocation = Cachehelper.getData(key: "myLocation");
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  bool offerloading = true;
  var price;
  var filters = [];
  Future GetofferData()async{
    setState(() {
      offerloading = false;
    });
    http.Response response = await http.get(Uri.parse('https://api.canariapp.com/v1/client/offers/${widget.id}?latitude=${latitud==null?27.149890:latitud}&longitude=${longitud==null?-13.199970:longitud}'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value){
      var responsebody = jsonDecode(value.body);
      printFullText(responsebody.toString());
      setState(() {
        offerloading = true;
      });



      filters = responsebody['stores'];
      filters.sort((a, b) => b["rate"].compareTo(a["rate"]));
      filters.sort((a, b) {
        // Sort open stores before closed stores
        if (a["is_open"] == true && b["is_open"] == false) {
          return -1;
        } else if (a["is_open"] == false && b["is_open"] == true) {
          return 1;
        }
        // If both stores have the same open status, sort them alphabetically by name
        return b["rate"].compareTo(a["rate"]);
      });

      List<String> slugs = [];
      filters.forEach((element) {
        slugs.add(element['slug']);
      });

      if(slugs.isNotEmpty)
        GetDeliveryPrice(slugs);
    }).catchError((error){
        print(error.toString());
    });
     return response;
  }

  bool ispriceLoading = true;
  List PriceDeliverys = [];
  GetDeliveryPrice(List slugs)async{
    print(slugs);
    String result = 'slugs[]=' + slugs.map((slug) => Uri.encodeQueryComponent(slug)).join('&slugs[]=');
    ispriceLoading = false;
    setState(() {
      print("https://www.api.canariapp.com/v1/client/stores/get_delivery_price?$result&latitude=${latitud}&longitude=${longitud}");
    });
    http.Response response = await http.get(
      Uri.parse('https://www.api.canariapp.com/v1/client/stores/get_delivery_price?$result&latitude=${latitud}&longitude=${longitud}'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){

      var responsebody = jsonDecode(value.body);
      print('----------------------------------');
      print("https://www.api.canariapp.com/v1/client/stores/get_delivery_price?$result&latitude=${latitud}&longitude=${longitud}");
      print('----------------------------------');
      PriceDeliverys = responsebody;
      ispriceLoading = true;

      setState(() {

      });
    }).catchError((onError){
      print(onError.toString());
      setState(() {

      });
    });

    return response;

  }
  @override
  void initState(){

    GetofferData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String MyLocation = Cachehelper.getData(key: "myLocation");
    double latitud = Cachehelper.getData(key: "latitude");
    double longitud = Cachehelper.getData(key: "longitude");
    printFullText(filters.toString());
    return StreamBuilder<ConnectivityResult>(
      stream:Connectivity().onConnectivityChanged,
      builder:(context,snapshot){
        return Scaffold(
            bottomSheet:snapshot.data==ConnectivityResult.none?buildNoNetwork():height(0),
            backgroundColor:Colors.white,
            appBar:AppBar(
              elevation:0,
              backgroundColor:Colors.white,
              leading: GestureDetector(
                  onTap: (){
                   Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back,color: Colors.black)),
              title:GestureDetector(
                onTap:(){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>SelectAddres(routing: 'homepage',)),(route) => false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children:[
                          MyLocation.length<=30?Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.black,),),
                                height(4),
                                Text(
                                  MyLocation!=null? "${MyLocation}":'اختر موقع',
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
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DemoLocalization.of(context).getTranslatedValue('Livrer_à'),style: TextStyle(fontSize:10,color: Colors.black,),),
                                  Text(
                                    MyLocation!=null? "${MyLocation}":'اختر موقع',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    lg!='ar'?Padding(
                      padding:EdgeInsets.only(left:0,right:0),
                      child:Center(
                        child:IconButton(onPressed:(){
                          navigateTo(context,Account(routing:'homepage'));
                        },
                            icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                      ),
                    ):Padding(
                      padding:EdgeInsets.only(left:0,right:0),
                      child:Center(
                        child:IconButton(onPressed:(){
                          navigateTo(context,Account(routing: 'homepage',));
                        },
                            icon:Icon(Icons.menu_rounded,color:Colors.black,size: 30,)),
                      ),
                    ),

                  ],
                )
              ],
            ),
            body:offerloading?SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:10,right:20,bottom:0),
                    child: GestureDetector(
                      onTap: (){
                        navigateTo(context,SearchStore());
                      },
                      child:Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:Color(0xFFf3f4f5),
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
                  height(5),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    child: FilterChip(
                        labelPadding:EdgeInsets.only(right: 15,left: 10) ,
                        labelStyle:TextStyle(fontSize: 12) ,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey[350],
                          width: 1,
                        ),
                        avatar: Icon(Icons.close,size: 15,),
                        label: Text('${widget.text}',),
                        onSelected: (s){
                          setState(() {
                            widget.text = "";
                          });
                          Navigator.pop(context);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,top: 10,bottom: 10,right: 18),
                    child:Text('${DemoLocalization.of(context).getTranslatedValue('resulate')} (${filters.length}) ',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    )),
                  ),
                  height(5),
                  filters.length==0?Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Image.network('https://canariapp.com/_nuxt/img/binoculars.9681313.png',),
                        Padding(
                          padding: const EdgeInsets.only(left: 25,right: 25,top: 10),
                          child: Text('لا يوجد مطعم متوفر بهذا الفلتر حاول مرة أخرى بفلتر مختلف',style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ):height(0),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        var Restaurant = filters[index];
                        var categories = Restaurant['categories'].length >= 3 ? Restaurant['categories'].sublist(0, 3) : Restaurant['categories'];
                        var offers = Restaurant['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList();

                        return GestureDetector(
                          onTap: ()async{
                            var totalPrice = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StorePage(
                                        paymentMethods:Restaurant['payment_methods'],
                                        name:Restaurant['name'],
                                        cover:Restaurant['cover'],
                                        price_delivery:Restaurant['delivery_price'],
                                        oldprice_delivery:Restaurant['delivery_price_old'],
                                        rate:Restaurant['rate'],
                                        deliveryTime:Restaurant['delivery_time'],
                                        cuisines: categories,
                                        id:Restaurant['id'],
                                        slug:Restaurant['slug'],
                                        brandlogo:Restaurant['logo'],
                                        tags:Restaurant['tags'],
                                        service_fee:Restaurant['service_fee']
                                    )));
                                    setState(() {
                                      price = totalPrice;
                                    });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 260,
                              child: Column(
                                children: [
                                  Stack(alignment:lg=='fr'?Alignment.topRight:Alignment.topLeft,

                                  children: [
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
                                          color:Restaurant['is_open']==false?Colors.grey[200]:Color(0xffeef2f5),
                                          child: Opacity(
                                            opacity:Restaurant['is_open']==false?0.5:1,
                                            child:CachedNetworkImage(
                                                height:250,
                                                width:double.infinity,
                                                imageUrl:'${Restaurant['cover']}',
                                                placeholder:(context, url) =>
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
                                    Restaurant['is_open']==false?
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 52),
                                        child: Container(
                                            width: 78,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: Color(0xFF383737),
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
                                    if(Restaurant['delivery_time']!=null)
                                      Padding(
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
                                              child: Text(' ${Restaurant['delivery_time']} ${DemoLocalization.of(context).getTranslatedValue('Second')} ',style: TextStyle(fontSize: 12.4,color: Colors.black,fontWeight: FontWeight.bold,),textAlign:TextAlign.center),
                                            )),
                                      ),

                                    if(Restaurant['tags'].length>0)
                                      offers.length>0?height(0):Padding(
                                        padding: const EdgeInsets.only(top: 10,right: 10,left: 10),
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
                                                      children: [
                                                        Image.asset('assets/discount.png',height: 20),
                                                        width(2),
                                                        Text('${e['ar']['name']}',
                                                          style:TextStyle(
                                                            color:Color(0xffff7144),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),),
                                                      ],
                                                    ),
                                                  ),
                                                  width:100,
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
                                            child:Image.network('${Restaurant['logo']}',fit:BoxFit.cover)),
                                      ),
                                      Padding(
                                       padding:EdgeInsets.only(left: 12,right: 10,top:Restaurant['delivery_time']==null?9:0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${Restaurant['name']}',
                                                  style:TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF000000),
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),

                                            ispriceLoading?Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 0,top: 0),
                                                  child:Row(
                                                    children: [
                                                      Icon(Icons.star,color:Restaurant['rate']>=3.5?Colors.green:Colors.grey[300],size:15),
                                                      width(5),
                                                      Text('${Restaurant['rate'].toStringAsFixed(1)}',style: TextStyle(
                                                          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                                                          fontSize: 11
                                                      ),),
                                                      width(5),
                                                      Restaurant['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                                                          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500
                                                      ),):Text(Restaurant['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                                                          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500
                                                      ),),
                                                      width(5),
                                                      rate(Restaurant['reviews_count'],Restaurant),
                                                    ],
                                                  ),
                                                ),
                                                Restaurant['reviews_count']<10?width(0):width(5),
                                                Container(
                                                  height: 5,
                                                  width: 5,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      shape: BoxShape.circle
                                                  ),),
                                                width(5),
                                                Icon(Icons.delivery_dining_outlined,color:PriceDeliverys.where((item)=>item['store_id']==Restaurant['id']).first['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                                                width(5),
                                                Text(
                                                    PriceDeliverys.where((item)=>item['store_id']==Restaurant['id']).first['delivery_price']!=0?'${PriceDeliverys.where((item)=>item['store_id']==Restaurant['id']).first['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                                                    style: TextStyle(
                                                        fontSize:11.5,
                                                        color:PriceDeliverys.where((item)=>item['store_id']==Restaurant['id']).first['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
                                                        fontWeight: FontWeight.w400)
                                                ),
                                                width(8),

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
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },itemCount:filters.length)
                ],
              ),
            ): SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchBarAndFilter(context),
                      ],
                    ),
                  ),
                  height(20),

                  Padding(
                    padding: const EdgeInsets.only(left: 15,top: 15,bottom: 15,right: 15),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      period: Duration(seconds: 2),
                      highlightColor: Colors.grey[100],
                      child: Container(
                        height: 15,
                        color: Colors.white,
                        child: Text('Result (${filters.length})',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),),
                      ),
                    ),
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 15,right: 15,bottom: 10),
                          child:
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(alignment: Alignment.topLeft, children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300],
                                    period: Duration(seconds: 2),
                                    highlightColor: Colors.grey[100],
                                    child: Container(
                                      height: 125,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),

                                      ),
                                    ),
                                  ),


                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300],
                                      period: Duration(seconds: 2),
                                      highlightColor: Colors.grey[100],
                                      child: Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 2,
                                              )),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image.network('',fit: BoxFit.cover,),)
                                      ),
                                    ),
                                  ),
                                ]),
                                height(10),
                                Padding(
                                  padding:EdgeInsets.only(left: 12,bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child:  Container(
                                          width: 180,
                                          color: Colors.grey,
                                          child: Text(
                                            '25 % off entire menu',
                                            style:TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red,
                                                fontSize: 11.8),
                                          ),
                                        ),
                                      ),

                                      height(5),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child:  Container(
                                          width: 200,
                                          color: Colors.grey,
                                          child: Text(
                                            '25 % off entire menu',
                                            style:TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red,
                                                fontSize: 11.8),
                                          ),
                                        ),
                                      ),
                                      height(5),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300],
                                        period: Duration(seconds: 2),
                                        highlightColor: Colors.grey[100],
                                        child: Container(
                                          color: Colors.grey,
                                          child: Text(
                                            '25 % off entire menu',
                                            style:TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red,
                                                fontSize: 11.8),
                                          ),
                                        ),
                                      ),
                                      // height(9),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                ],
              ),
            )
        );
      },

    );
  }

  Widget rate(rate_count,Restaurant){
    if (rate_count > 20) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('20',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0,bottom: 2),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
        ],
      );
    } else if(rate_count > 10){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('+',style: TextStyle(
              color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold
          ),
            textAlign: TextAlign.center,
          ),
          Text('10',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),

          Text(')',style: TextStyle(
            fontSize: 10,
            color:Restaurant['rate']>=3.0?Colors.green:Colors.grey,
          ),),
        ],
      );
    } else {
      return Text(rate_count<10?"":'${rate_count}');
    }
  }


  // Widget buildReview(){
  //   return  Padding(
  //     padding: const EdgeInsets.only(right: 0,top: 3),
  //     child:widget.Restaurant['reviews_count']<10?height(0): Row(
  //       children: [
  //         Icon(Icons.star,color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey[300],size:18),
  //         width(5),
  //         Text('${widget.Restaurant['rate'].toStringAsFixed(1)}',style: TextStyle(
  //             color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
  //             fontSize: 12
  //         ),),
  //         width(5),
  //         Text('ممتاز',style: TextStyle(
  //             color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500
  //         ),),
  //         width(5),
  //         rate(widget.Restaurant['reviews_count']),
  //       ],
  //     ),
  //   );
  // }
}
