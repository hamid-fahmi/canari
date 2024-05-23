import 'package:flutter/material.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/shared/components/constants.dart';

class StoreCategories extends StatefulWidget {
  StoreCategories({
    Key key,
    @required this.cubit,
    @required this.selectedIndex, this.onchange,
  }) : super(key: key);

  final StoreCubit cubit;
  int selectedIndex;
  final ValueChanged<int>onchange;

  @override
  State<StoreCategories> createState() => _StoreCategoriesState();
}

class _StoreCategoriesState extends State<StoreCategories> {
  ScrollController controller;
  @override
  void initState() {
   controller = ScrollController();
    super.initState();
  }
  @override
  void didUpdateWidget(covariant StoreCategories oldWidget) {
    controller.animateTo(60.0*widget.selectedIndex,
     duration: Duration(milliseconds: 100),
      curve: Curves.bounceIn);
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: Row(
              children:List.generate(widget.cubit.store['menus'].length,(index) =>Padding(
                padding: const EdgeInsets.only(left: 15,right: 10),
                child: GestureDetector(
                  onTap:(){
                    setState(() {
                       widget.onchange(index);
                      widget.selectedIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: widget.selectedIndex==index?BorderSide(width: 3.0,color: Colors.red):BorderSide.none
                      ),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${capitalize('${widget.cubit.store['menus'][index]['name']}')}',
                        style: TextStyle(
                          fontWeight:widget.selectedIndex!=index? FontWeight.w500:FontWeight.bold,
                          color: widget.selectedIndex==index?AppColor:Color(0xff7F8487),
                          fontSize: 15),),

                      ],
                    ),
                  ),
                ),
              ))
            ),
    );
  }
}
