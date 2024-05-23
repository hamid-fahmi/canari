import 'dart:collection';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/shared/components/components.dart';
import '../../../Layout/HomeLayout/account.dart';
import '../../../Layout/HomeLayout/searchStore.dart';
import '../../../Layout/HomeLayout/selectAddres.dart';
import '../../../localization/demo_localization.dart';
import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';
import '../../../widgets/storeGridl.dart';

class FilterPage extends StatefulWidget {
  final Categories;
  var text;
  FilterPage({Key key,  this.text,this.Categories}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {



  HashSet selectCategories = new HashSet();
  List filters = [];
  @override
  Widget build(BuildContext context) {
    String MyLocation = Cachehelper.getData(key: "myLocation");
    double latitud = Cachehelper.getData(key: "latitude");
    double longitud = Cachehelper.getData(key: "longitude");
    return BlocProvider(
      create: (context)=>StoreCubit()..FilterData(latitude: latitud,longitude: longitud,text: widget.text),
     child:  BlocConsumer<StoreCubit,ShopStates>(
       listener:(context,state){
          if(state is GetFilterDataSucessfulState){
            filters = state.filters;
          }
       },
       builder:(context,state){
         var cubit = StoreCubit.get(context);
         return StreamBuilder<ConnectivityResult>(
           stream: Connectivity().onConnectivityChanged,
           builder: (context,snapshot){
             return Scaffold(
                 bottomSheet:snapshot.data==ConnectivityResult.none?buildNoNetwork():height(0),
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
                 body:cubit.isloading? SingleChildScrollView(
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
                           cubit.FilterData(
                             longitude: longitud,
                             latitude: latitud,
                             text: widget.text,
                           );
                         });
                         Navigator.pop(context);
                       }),
                 ),
                       Padding(
                         padding: const EdgeInsets.only(left: 15,top: 10,bottom: 10,right: 18),
                         child: Text('${DemoLocalization.of(context).getTranslatedValue('resulate')} (${filters.length}) ',style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 15
                         ),),
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
                             return Padding(
                               padding: const EdgeInsets.only(left: 15,right: 15,bottom: 20),
                               child: StoreGridl(Restaurant:filters[index],id:filters[index]['id'],size: 220.0,ispriceLoading: cubit.ispriceLoading,PriceDeliverys:cubit.PriceDeliverys),
                             );
                           },itemCount: filters.length)
                     ],
                   ),
                 ): SingleChildScrollView(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
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
       },
     )
    );
  }
   buildFilter({HashSet selectFilters, List categories}){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(left:15,top: 20,right: 10),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
            //
            // Padding(
            //   padding: const EdgeInsets.only(left: 7,top: 10),
            //   child: Text("مرشحات شعبية",style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold
            //   ),),
            // ),
            // height(15),
            // ...Popular_Filters.map((e) {
            //   return
            //     StatefulBuilder(
            //       builder:(context,state){
            //         return GestureDetector(
            //           onTap: () {
            //             state(() {
            //               if (selectFilters.contains(e)) {
            //                 selectFilters.remove(e);
            //               } else {
            //                 selectFilters.add(e);
            //               }
            //               print(selectFilters);
            //             });
            //           },
            //           child: Padding(
            //             padding: const EdgeInsets.only(left: 10,right: 15,top: 10,bottom: 10),
            //             child: Container(
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Text('${e}',style: TextStyle(
            //                       color: Color(0xFF828894),
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w500
            //                   ),),
            //                   Icon(selectFilters.contains(e)?Icons.check_box:Icons.check_box_outline_blank,color:selectFilters.contains(e)?Colors.red:Color(0xFF828894)),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         );
            //       },
            //     );
            // }),
            Padding(
              padding: const EdgeInsets.only(left: 7,top: 15),
              child: Text("فئات",style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),),
            ),
            height(15),

            ...widget.Categories.map((e) {
              return StatefulBuilder(
                  builder:(context,state){
                    return GestureDetector(
                      onTap: () {
                        state(() {
                          if (selectFilters.contains(e['name'])) {
                            selectFilters.remove(e['name']);
                          } else {
                            selectFilters.add(e['name']);
                          }
                          print(selectFilters);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10,right: 15,top: 10,bottom: 10),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${e['name']}',style: TextStyle(
                                  color: Color(0xFF828894),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                              ),
                              ),
                              Icon(selectFilters.contains(e['name'])?Icons.check_box:Icons.check_box_outline_blank,color:selectFilters.contains(e['name'])?Colors.red:Color(0xFF828894)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
            }),
          ],
        ),
      ),
    );
  }
}
