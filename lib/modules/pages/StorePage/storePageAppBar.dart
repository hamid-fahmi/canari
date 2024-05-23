import 'package:flutter/material.dart';
import 'package:shopapp/modules/pages/StorePage/store_page.dart';

class StorePageAppBar extends StatelessWidget {
  const StorePageAppBar({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final StorePage widget;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 195,
      pinned: true,
      title: Text('${widget.name}',
      style: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold),),
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace:FlexibleSpaceBar(
      background: Image.network('${widget.cover}',fit: BoxFit.cover,),
      ),
      leading: Padding(
        padding:EdgeInsets.only(left: 16),
        child:GestureDetector(
          onTap:(){
            Navigator.of(context).pop();
          },
        child:CircleAvatar(child: Icon(Icons.arrow_back,color: Colors.black,size: 26),backgroundColor: Colors.white,minRadius: 22),),
      ),
      actions: [
        Padding(
           padding: EdgeInsets.only(right: 16,left: 16),
          child:CircleAvatar(child: Icon(Icons.search,color: Colors.black,size: 26),backgroundColor: Colors.white,minRadius: 22),
        )
      ],
    );
  }
}
