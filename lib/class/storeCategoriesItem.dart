import 'package:flutter/material.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';

import '../modules/pages/StorePage/storeCategories.dart';

class StoreCategoriesItem extends SliverPersistentHeaderDelegate{
   final int selectedIndex;
   final isShow ;
   final StoreCubit cubit;
   final ValueChanged<int>onchanged;
   StoreCategoriesItem( {this.selectedIndex,this.cubit,this.onchanged,this.isShow});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
   return cubit.store['menus'].length!=0? Container(
     height: 52,
     decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
       isShow?  BoxShadow(
                 color: Colors.grey.withOpacity(0.2),
                 spreadRadius: 2,
                 blurRadius: 4,
                 offset: Offset(1, 2), // changes position of shadow
               ):BoxShadow(
         color: Colors.grey.withOpacity(0.0),
         spreadRadius: 1,
         blurRadius: 2,
         offset: Offset(0, 0), // changes position of shadow
       )
      ]
     ),
     child:StoreCategories(
       cubit: cubit,
        selectedIndex:selectedIndex,
        onchange: onchanged,
        ),
   ):Container(
     height: 52,
     child: Text(''),
   );
  }

  @override
  double get maxExtent => 52;
  @override
  double get minExtent =>52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}
