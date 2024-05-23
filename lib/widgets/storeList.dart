import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';

import '../localization/demo_localization.dart';
import '../modules/pages/StorePage/store_page.dart';

class StoreList extends StatelessWidget {
  final Restaurant;
  final id;
  final ispriceLoading;
  final PriceDeliverys;
  const StoreList({
    Key key, this.Restaurant, this.id,this.ispriceLoading,this.PriceDeliverys
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    return Padding(
      padding: const EdgeInsets.only(left: 2,top: 0,bottom: 10),
      child: InkWell(
        onTap: (){
           Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StorePage(
                          name:Restaurant['name'],
                          slug:Restaurant['slug'],
                          cover:Restaurant['cover'],
                          price_delivery:Restaurant['delivery_price'],
                          oldprice_delivery:Restaurant['delivery_price_old'],
                          rate:Restaurant['rate'],
                          deliveryTime:Restaurant['delivery_time'],
                          cuisines:Restaurant['categories'],
                          id:id,
                          brandlogo:Restaurant['logo'],
                          tags:Restaurant['tags'],
                          service_fee:Restaurant['service_fee'],
                          paymentMethods:Restaurant['payment_methods'],
                        )));
        },
        child: Container(
          child: Row(
          children: [
          Padding(
           padding: const EdgeInsets.only(left: 0,bottom: 0),
           child:
           Container(
             width: 75,
             height: 75,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(5),
             ),
             child:ClipRRect(
                 borderRadius: BorderRadius.circular(5),
                 child:CachedNetworkImage(
                     imageUrl: '${Restaurant['logo']}',
                     placeholder: (context, url) =>
                         Image.asset('assets/placeholder.png',fit: BoxFit.cover),
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
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                 Padding(
                 padding: const EdgeInsets.only(right: 10,left: 10),
                 child: Text(
                   '${Restaurant['name']}',
                    style:TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Color(0xFF000000),
                       fontSize: 15),
                 ),
               ),
                   if(Restaurant['tags'].length>0)
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
                   )
                 ],
               ),
               height(3),
               Padding(
                 padding: const EdgeInsets.only(right: 10,left: 10),
                 child: Text('${Restaurant['categories'].map((item) => item['name']).join(' , ')}',style: TextStyle(
                   fontSize: 11.2,
                   fontWeight: FontWeight.w500,
                 ),),
               ),
               height(3),

               Padding(
                 padding: const EdgeInsets.only(right: 10,top: 3,left: 10),
                 child: Row(
                   children:[
                     Icon(Icons.star,color:Restaurant['rate']>=3.5?Colors.green:Colors.grey[300],size:18),
                     width(5),
                     Text('${Restaurant['rate'].toStringAsFixed(1)}',style: TextStyle(
                         color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                         fontSize: 12
                     ),),
                     width(5),
                      Restaurant['rate']<=2?Text(DemoLocalization.of(context).getTranslatedValue('normale'),style: TextStyle(
                         color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500
                     ),):Text(Restaurant['rate']>=3.5?DemoLocalization.of(context).getTranslatedValue('excellent'):DemoLocalization.of(context).getTranslatedValue('bien'),style: TextStyle(
                         color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500
                     ),),
                     width(5),
                     Rate(Restaurant['reviews_count'],Restaurant),
                     Restaurant['reviews_count']<10?width(0):width(5),
                     Container(
                       height: 5,
                       width: 5,
                       decoration: BoxDecoration(
                           color: Colors.grey[300],
                           shape: BoxShape.circle
                       ),),
                      width(4),
                     Row(
                       children: [
                         Icon(Icons.delivery_dining_outlined,color: Restaurant['delivery_price']!=0?Colors.black:AppColor,size: 14,),
                         width(5),
                         Text(
                             Restaurant['delivery_price']!=0?'${Restaurant['delivery_price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ':DemoLocalization.of(context).getTranslatedValue('livraison_gratuite'),
                             style: TextStyle(
                                 fontSize:10.5,
                                 color:Restaurant['delivery_price']!=0? Color.fromARGB(255, 78, 78, 78):AppColor,fontWeight:FontWeight.w400)
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
             ],
           ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget Rate(rate_count,Restaurant){
    if (rate_count > 20) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('20',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
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
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Text('10',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
            color:Restaurant['rate']>=3.0?Colors.green:Colors.grey,
          ),),
        ],
      );
    } else {
      return Text(rate_count<10?"":'${rate_count}');
    }
  }


  Widget rate(rate_count){
    if (rate_count > 20) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
              color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
          Text('20',style: TextStyle(
              color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                  color: Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
              color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
        ],
      );
    } else if(rate_count > 10){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(',style: TextStyle(
              color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
          Text('10',style: TextStyle(
              color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(height: 13,width: 10,color: Colors.white,child: Center(
              child: Text('+',style: TextStyle(
                color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
              ),
            ),),
          ),
          Text(')',style: TextStyle(
            color: Restaurant['rate']>=3.5?Colors.green:Colors.grey
          ),),
        ],
      );
    } else {
      return Text(rate_count<10?"":'${rate_count}');
    }
  }
}