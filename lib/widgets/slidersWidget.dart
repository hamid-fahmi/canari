import 'dart:collection';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:buildcondition/buildcondition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/modules/pages/Static/couponPage.dart';
import 'package:shopapp/modules/pages/Static/support_service.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:shopapp/shared/network/remote/cachehelper.dart';
import 'package:http/http.dart' as http;
import '../class/services.dart';
import '../modules/pages/StorePage/store_page.dart';
import '../modules/pages/Static/filterPage.dart';
import '../modules/pages/Static/offer.dart';
import '../modules/pages/Static/share.dart';
import '../Utils/web.dart';
final services = new Services();
class SlidersWidget extends StatefulWidget {
  SlidersWidget({
    Key key, @required this.selectFilters,
  }) : super(key: key);

  final HashSet selectFilters;


  @override
  State<SlidersWidget> createState() => _SlidersWidgetState();
}

class _SlidersWidgetState extends State<SlidersWidget> {

  bool isSlidersLoading = false;
  List sliders = [];
  Future<void> GetSiders() async{
    isSlidersLoading = false;
    String access_token = Cachehelper.getData(key: "token");
    http.Response response = await http.get(Uri.parse('https://api.canariapp.com/v1/client/sliders?type=${service_type}&include=stores.categories'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value)async{
      var responsebody = jsonDecode(value.body);
      setState(() {
        isSlidersLoading = true;
        sliders = responsebody;
      });
    }).catchError((onError){

    });
    return response;
  }

  @override
  void initState() {
    GetSiders();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return BuildCondition(
      condition:isSlidersLoading,
      builder: (context){
        return Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: sliders.length>0?Container(
              height:120,
              width:double.infinity,
              child: CarouselSlider(
                items:sliders.map((item) {
                  return Builder(
                    builder: (BuildContext context){
                      return Padding(
                        padding: const EdgeInsets.only(right: 12,),
                        child: GestureDetector(
                          onTap: ()async{
                            if(item['type']=='deep_link'){
                              if(item['value']=='supportPage'){
                                navigateTo(context,SupportService());
                              }
                              if(item['value']=='invite'){
                                navigateTo(context,Share());
                              }
                              if(item['value']=='coupone'){
                                navigateTo(context,CoupondPage());
                              }
                            }

                            if(item['type']=='category'){
                              navigateTo(context, FilterPage(text:item['value']));
                            }

                            if(item['type']=='offer'){
                              navigateTo(context,Offer(text:item['name'],id:item['value'],));
                            }

                            if(item['type']=='store'){
                                 var categories = item['value']['categories'].length >= 3 ? item['value']['categories'].sublist(0, 3) : item['value']['categories'];
                                var totalPrice = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StorePage(
                                          name: item['value']['name'],
                                          cover: item['value']['cover'],
                                          price_delivery:item['value']['delivery_price'],
                                          oldprice_delivery:item['value']['delivery_price_old'],
                                          rate:item['value']['rate'],
                                          cuisines:categories,
                                          id:item['value']['id'],
                                          slug:item['value']['slug'],
                                          brandlogo:item['value']['logo'],
                                          tags: item['value']['tags'],
                                          service_fee:item['value']['service_fee']
                                        )));
                                setState(() {});
                            }

                            if(item['type']=='online_link'){
                              print(item);
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Web(url:item['value'],name: item['name'],)
                                  )
                              );
                              setState(() {});
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffeef2f5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                  imageUrl: '${item['image']}',
                                  placeholder: (context, url) =>
                                      Container(
                                        child: Image.asset('assets/placeholder.png',fit: BoxFit.cover),
                                        height:135,
                                        width:double.infinity,
                                      ),
                                  errorWidget: (context, url, error) =>Container(
                                    child: Image.asset('assets/placeholder.png',fit: BoxFit.cover),
                                    height:135,
                                    width:double.infinity,
                                  ),
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
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 135,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: false,
                  aspectRatio: 16 / 5 ,
                ),
              ),
            ):height(0),
          );
      },
      fallback: (context){
      return  Padding(
        padding: const EdgeInsets.only(left: 15,right: 15),
        child: Container(
            width:double.infinity,
            height:135,
            color:Colors.white,
            child:ListView.separated(
                separatorBuilder:(context,index){
                  return width(12);
                },
                physics:BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount:6,
                itemBuilder:(context,index){
                  return Shimmer.fromColors(
                     baseColor:Colors.grey[300],
                     period:Duration(seconds:2),
                     highlightColor:Colors.grey[100],
                    child: Container(
                      decoration:BoxDecoration(borderRadius: BorderRadius.circular(5),color:Colors.grey),
                      height:135,
                      width:280,
                    ),
                  );
                })),
      );
      },
    );
  }
}