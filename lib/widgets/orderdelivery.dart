import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import '../Layout/HomeLayout/account.dart';
import '../Layout/HomeLayout/selectAddres.dart';
import '../Layout/shopcubit/storestate.dart';
import '../localization/demo_localization.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/network/remote/cachehelper.dart';
import 'storeGridl.dart';

class OrderDelivery extends StatefulWidget {

  const OrderDelivery({Key key,}) : super(key: key);

  @override
  State<OrderDelivery> createState() => _OrderDeliveryState();
}

class _OrderDeliveryState extends State<OrderDelivery> {
  String MyLocation = Cachehelper.getData(key: "myLocation");
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => StoreCubit()..getStoresData(latitude: latitud==null?27.149890:latitud,longitude: longitud==null?-13.199970:longitud),
        child: BlocConsumer<StoreCubit, ShopStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = StoreCubit.get(context);
            var search = StoreCubit.get(context).search;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar:AppBar(
                    elevation:0,
                    // automaticallyImplyLeading: false,
                    // leading:Icon(Icons.arrow_back,color: Colors.black),
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
                                navigateTo(context,Account(routing: 'homepage',));
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
                  body:SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                       Padding(padding: EdgeInsets.only(right:8),child:title(text: 'توصيل مجاني',size: 16,color:Colors.black),),
                        height(20),
                        cubit.stores.length>0?ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider(
                                height: 1,
                              );
                            },
                            itemCount:cubit.stores.length,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = cubit.stores[index];
                              return Padding(
                                padding:EdgeInsets.only(left: 20,right: 20,bottom: 15),
                                child: StoreGridl(Restaurant: item,id:item['id'],size: 220.0,ispriceLoading:cubit.ispriceLoading,PriceDeliverys: cubit.PriceDeliverys),
                              );
                            }):ListView.separated(
                              separatorBuilder: (context, index) {
                                return width(10);
                              },
                              physics: BouncingScrollPhysics(),
                              itemCount:7,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),

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
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  height: 125,
                                                  width: double.infinity,

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



                      ],
                    ),
                  )),
            );
          },
        ),
      );
  }
}
