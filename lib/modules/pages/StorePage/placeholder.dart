import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/shared/components/components.dart';

class placeholder extends StatelessWidget {
  const placeholder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey,
            ),
          ),
          height(15),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 15,
          width: 90,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
    fontWeight: FontWeight.normal,
    color: Color(0xFF000000),
    fontSize: 15),
          ),
        ),
      ),
      Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 15,
          width: 60,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
    fontWeight: FontWeight.normal,
    color: Color(0xFF000000),
    fontSize: 15),
          ),
        ),
      ),
              ],
            ),
          ),
          height(5),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child:Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 13,
          width: 40,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
    fontWeight: FontWeight.normal,
    color: Color(0xFF000000),
    fontSize: 15),
          ),
        ),
      ),
          ),
          height(10),
          ListView.separated(
            separatorBuilder: (context,index){
              return Divider();
            },
            itemCount: 7,
            shrinkWrap: true,
            itemBuilder: (contex,index){
            return Product();
          })
        ],
      ),
    );
  }
}

class Product extends StatelessWidget {
  const Product({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 10),
      child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
         Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 13,
          width: 40,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF000000),
                fontSize: 15),
          ),
        ),
      ),
      
                      ],
                    ),
                    height(5),
                    Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 13,
          width: 150,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF000000),
                fontSize: 15),
          ),
        ),
      ),
                    height(9),
                    Shimmer.fromColors(
         baseColor: Colors.grey[300],
         highlightColor: Colors.grey[100],
        child: Container(
          height: 13,
          width: 60,
          color: Colors.grey,
          child: Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF000000),
                fontSize: 15),
          ),
        ),
      ),
                    height(9),
                  ],
                ),
              ),
              width(15),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                     color: Colors.grey
                    ),
                    
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
