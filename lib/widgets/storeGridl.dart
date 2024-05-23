import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';

import '../localization/demo_localization.dart';
import '../modules/pages/StorePage/store_page.dart';

class StoreGridl extends StatefulWidget {
  final Restaurant;
  final id;
  final size;
  final ispriceLoading;
  final PriceDeliverys;
  StoreGridl({
    Key key, this.Restaurant, this.id,this.size,this.ispriceLoading,this.PriceDeliverys
  }) : super(key: key);

  @override
  State<StoreGridl> createState() => _StoreGridlState();
}

class _StoreGridlState extends State<StoreGridl> {
  var price;
  @override
  Widget build(BuildContext context) {
    var categories = widget.Restaurant['categories'].length >= 3 ? widget.Restaurant['categories'].sublist(0, 3) : widget.Restaurant['categories'];
    var offers = widget.Restaurant['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList();
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    return
      InkWell(
      onTap: ()async{
        var totalPrice = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StorePage(
                          name:widget.Restaurant['name'],
                          cover:widget.Restaurant['cover'],
                          price_delivery:widget.Restaurant['delivery_price'],
                          oldprice_delivery:widget.Restaurant['delivery_price_old'],
                          rate: widget.Restaurant['rate'],
                          deliveryTime:widget.Restaurant['delivery_time'],
                          cuisines: categories,
                          id:widget.id,
                          slug:widget.Restaurant['slug'],
                          brandlogo:widget.Restaurant['logo'],
                          tags: widget.Restaurant['tags'],
                          service_fee:widget.Restaurant['service_fee'],
                          paymentMethods:widget.Restaurant['payment_methods'],
                        )));
        setState(() {
          totalPrice = price;
        });
      },
      child: Container(
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(10),
       ),
       width: 300,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Stack(alignment:lg!='ar'?Alignment.topLeft:Alignment.topRight,children: [
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
                   color:widget.Restaurant['is_open']==false?Colors.grey[200]:Color(0xffeef2f5),
                   child: Opacity(
                     opacity:widget.Restaurant['is_open']==false?0.5:1,
                     child:CachedNetworkImage(
                         height:250,
                         width:double.infinity,
                         imageUrl:'${widget.Restaurant['cover']}',
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
             widget.Restaurant['is_open']==false?
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
             if(widget.Restaurant['delivery_time']!=null)
             Padding(
               padding: const EdgeInsets.only(top: 110,left: 10,right: 10),
               child: Align(
                 alignment:lg!='ar'?Alignment.topRight:Alignment.topLeft,
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
                           child: Text(' ${widget.Restaurant['delivery_time']} ${DemoLocalization.of(context).getTranslatedValue('Second')} ',style: TextStyle(fontSize: 12.4,color: Colors.black,fontWeight: FontWeight.bold,),textAlign:TextAlign.center),
                         )),
               ),
             ),

             if(widget.Restaurant['tags'].length>0)
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
                      child:Padding(
                        padding: const EdgeInsets.only(top: 4,left: 6,right: 6,bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/discount.png',height: 20),
                            SizedBox(width: 8.0),
                            Text(
                              '${e['name']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:TextStyle(
                              color:Color(0xffff7144),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,)
                            ),
                          ],
                        ),
                      ),
                    )
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
                     child:Image.network('${widget.Restaurant['logo']}',fit:BoxFit.cover)
                 ),
                 ),
               Padding(
                 padding:EdgeInsets.only(left: 5,right: 10,top:widget.Restaurant['delivery_time']==null?9:0),
                 child: Column(
                   crossAxisAlignment:CrossAxisAlignment.start,
                   mainAxisAlignment:MainAxisAlignment.center,
                   children:[
                     Row(
                       children: [
                         Text(
                           '${widget.Restaurant['name']}',
                            style:TextStyle(
                               fontWeight: FontWeight.bold,
                               color: Color(0xFF000000),
                               fontSize: 16),
                         ),
                       ],
                     ),
                     height(6),


                     widget.PriceDeliverys.where((item)=>item['store_id']==widget.Restaurant['id']).toList().length>0?Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       mainAxisAlignment: MainAxisAlignment.start,
                       children:[
                         Icon(Icons.star,color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey[300],size:15),
                         width(5),
                         Text('${widget.Restaurant['rate'].toStringAsFixed(1)}',style: TextStyle(
                             color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                             fontSize: 10
                         ),),
                         width(5),
                         widget.Restaurant['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                             color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                             fontSize: 10,
                             fontWeight: FontWeight.w500
                         ),):Text(widget.Restaurant['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                             color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                             fontSize: 10,
                             fontWeight: FontWeight.w500
                         ),),
                         width(5),
                         Rate(widget.Restaurant['reviews_count'],widget.Restaurant),
                         widget.Restaurant['reviews_count']<10?width(0):width(5),
                         Container(
                           height: 5,
                           width: 5,
                           decoration: BoxDecoration(
                               color: Colors.grey[300],
                               shape: BoxShape.circle
                           ),),

                         width(4),
                         widget.size==140?widget.Restaurant['reviews_count']<10?height(0):width(0):height(0),
                         Icon(Icons.delivery_dining_outlined,color:widget.PriceDeliverys.where((item)=>item['store_id']==widget.Restaurant['id']).first['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                          width(5),
                         Text(
                             widget.PriceDeliverys.where((item)=>item['store_id']==widget.Restaurant['id']).toList()[0]['delivery_price']!=0?'${widget.PriceDeliverys.where((item)=>item['store_id']==widget.Restaurant['id']).first['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                            style: TextStyle(
                             fontSize:9,
                             color:widget.PriceDeliverys.where((item)=>item['store_id']==widget.Restaurant['id']).first['delivery_price']!=0?  Color.fromARGB(255, 78, 78, 78):AppColor,
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


                     // height(9),
                   ],
                 ),
               ),
             ],
           ),
           height(2),
         ],
       ),
            ),
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

  Widget buildReview(){
    return  Padding(
      padding: const EdgeInsets.only(right: 0,top: 3),
      child:widget.Restaurant['reviews_count']<10?height(0):Row(
        children: [
          Icon(Icons.star,color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey[300],size:18),
          width(5),
          Text('${widget.Restaurant['rate'].toStringAsFixed(1)}',style:TextStyle(
              color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
              fontSize: 12
          ),),
          width(5),
          Text(DemoLocalization.of(context).getTranslatedValue('excellent'),style:TextStyle(
              color:widget.Restaurant['rate']>=3.5?Colors.green:Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500
          ),),
          width(5),
          rate(widget.Restaurant['reviews_count'],widget.Restaurant),
        ],
      ),
    );
  }
}
