import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/modules/pages/StorePage/store_page.dart';
import 'package:shopapp/shared/components/components.dart';

class StoreInfo extends StatefulWidget {
final StorePage widget;
final StoreCubit cubit;
StoreInfo({this.widget, this.cubit});

  @override
  State<StoreInfo> createState() => _StoreInfoState();
}

class _StoreInfoState extends State<StoreInfo> {
  @override
  Widget build(BuildContext context){
    return
      SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 0,top: 0,right: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${widget.widget.name}',
                      style: TextStyle(
                                      color: Colors.black,
                                       fontSize: 18,
                                      fontWeight: FontWeight.bold),),
                                     GestureDetector(
                                       onTap: (){
                                         showModalBottomSheet(
                                           isScrollControlled: true,
                                           context: context, builder:(context){
                                           return Directionality(
                                               textDirection: TextDirection.rtl,
                                               child: InfoResturant(context));
                                         } );
                                       },
                                       child: Row(
                                         children: [
                                           Icon(Icons.info_outline_rounded,color: Color.fromARGB(255, 78, 78, 78),size: 16),
                                           width(3),
                                           Text('معلومات', style: TextStyle(
                                            color: Color.fromARGB(255, 78, 78, 78),
                                             fontSize: 12,
                                            fontWeight: FontWeight.bold),),
                                         ],
                                       ),
                                     ),
                    ],
                  ),
                  height(3),
                  Row(
                    children: [
                      Padding(
                        padding:const EdgeInsets.only(left: 0,right: 0,top: 2),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color.fromARGB(255, 253, 207, 3),
                                  size: 15,
                                ),

                                width(5),
                                Text(
                                  "${widget.widget.rate}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 78, 78, 78),),
                                ),
                                width(5),
                                Text(
                                  "ممتاز",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 78, 78, 78),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                     width(5),
                     Container(
                       height: 5,
                         width: 5,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(15),
                         color: Colors.black,
                       ),


                     ),
                      width(5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          ...widget.widget.cuisines.map((cuisines) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                '${cuisines['name']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 78, 78, 78),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget InfoResturant(BuildContext context) {
    return
      Column(
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
                    imageUrl: '${widget.widget.cover}',
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
                          imageUrl: '${widget.widget.brandlogo}',
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
                        '${widget.widget.name}',
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
                      children: [
                        ...widget.widget.cuisines.map((cuisine) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 5,right: 5),
                            child: Text(
                              '${cuisine['name']}',
                              style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 52, 52, 52),
                                    ),
                                  ],
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                      ],
                    )
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
             infoItem(icon: Icons.emoji_emotions_outlined,infotitel: 'جيد',InfoDescript: '${widget.widget.rate} تقييم '),
             height(15),
             Container(height: 0.1,width:double.infinity ,color: Colors.black,),
             height(15),
             infoItem(icon: Icons.location_on_outlined,infotitel: 'منطقة المطعم',InfoDescript: '${widget.cubit.store['address']}'),
             if(widget.widget.deliveryTime!=null)
             height(15),
             if(widget.widget.deliveryTime!=null)
             Container(height: 0.1,width:double.infinity ,color: Colors.black,),
             height(15),
             if(widget.widget.deliveryTime!=null)
             infoItem(icon: Icons.delivery_dining_outlined,infotitel: 'موعد التسليم',InfoDescript: '${widget.widget.deliveryTime} دقيقة '),
             if(widget.widget.deliveryTime!=null)
             height(15),
             Container(height: 0.1,width:double.infinity ,color: Colors.black,),
             height(15),
             infoItem(icon: Icons.account_balance_wallet_outlined,infotitel: 'الحد الأدنى للطلب',InfoDescript: '${widget.cubit.store['min_amount']} درهم '),
             height(15),
             Container(height: 0.1,width:double.infinity ,color: Colors.black,),
             height(15),
             infoItem(icon: Icons.feed_outlined,infotitel: 'رسوم التوصيل',InfoDescript: widget.widget.price_delivery!=0?'${widget.widget.price_delivery}  درهم ':"توصيل مجاني"),
             height(15),
             Container(height: 0.1,width:double.infinity ,color: Colors.black,),

           ],
         ),
       )
      ],
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
                          width(15),
                          Text(infotitel,
                          style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15,bottom: 5),
                        child: Container(
                          width: 200,

                          child: Text(InfoDescript,
                             textDirection: TextDirection.ltr,
                             style: TextStyle(
                             color: Color.fromARGB(255, 78, 78, 78),
                             fontSize: 14,
                             fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  );
  }
}
