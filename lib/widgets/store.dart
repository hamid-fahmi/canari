import 'package:buildcondition/buildcondition.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/widgets/storeGridl.dart';

class Store extends StatelessWidget {
  Store({
    Key key,
   this.tag,
    @required this.cubit,this.status,
  }) : super(key: key);

  final StoreCubit cubit;
  final String status;
  final String tag;
  @override
  Widget build(BuildContext context) {

    return
      BuildCondition(
      condition:cubit.isRestaurantsLoading,
      builder: (context){
        final newStores =  cubit.stores.where((store) => store['tags'].contains('new')).toList();
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 0),
          child: Container(
            height: 190,
            color: Colors.white,
            child:ListView.builder(
              scrollDirection:Axis.horizontal,
              itemCount:status=='freedelivery' ? cubit.stores.where((element) => element['delivery_price']==0).toList().length:cubit.stores.length,
              shrinkWrap:true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index){
                return Padding(
                  padding:EdgeInsets.only(left: 0,right: 10,bottom: 0),
                  child: StoreGridl(ispriceLoading:cubit.ispriceLoading,Restaurant:status=='freedelivery'?cubit.stores.where((element) => element['delivery_price']==0).toList()[index]:cubit.stores[index],id:cubit.stores[index]['id'],size: 140.0,PriceDeliverys:cubit.PriceDeliverys),
                );
              }),
          ),
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
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
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
                           decoration: BoxDecoration(
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
              );
            },
          ),
          ),
        );
      },
    );
  }
}

