import 'package:flutter/material.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:shopapp/widgets/storeGridl.dart';
import 'package:shopapp/widgets/storeList.dart';

class CategoriePageDetails extends StatefulWidget {
  final String CategorieName;
  final dynamic resturant;
  const CategoriePageDetails({ Key key, this.CategorieName, this.resturant }) : super(key: key);

  @override
  _CategoriePageDetailsState createState() => _CategoriePageDetailsState();
}

class _CategoriePageDetailsState extends State<CategoriePageDetails> {
  bool islist =true;
  List CategoryRestaurant =[
      {
        "id":1,
        "name": "Motlen Chocolate",
        "slug":"motlen-chocolate",
        "cuisines": ["Sandwiches", "Italian", "Fast Food"],
        "brand_logo":"https://hsaa.hsobjects.com/h/restaurants/logo_ars/000/003/933/68182e31599ffd53989e14419e6b80b7-small.jpg",
        "cover":"https://rs-menus-api.roocdn.com/images/2ed4f62c-94c1-4e3f-af1e-f1bef1d0c9c1/image.jpeg?width=540&height=303&auto=webp&format=jpg&fit=crop",
        "deliveryTime": "15",
        "rate": 2.3,
        "delivery_price": 0,
        "offers":[
            {
              "id":1,
              "percentage": "-40%",
              "offer": " 40% off entire menu"
            }
        ],
        "statu":"open"
      },
      {
        "id":2,
        "name": "McDonald’s",
        "slug": "McDonald's",
        "cuisines": ["American", "Burgers", "Chicken"],
        "brand_logo":
            "https://hsaa.hsobjects.com/h/restaurants/logo_ars/000/000/001/1a3799fbc74b9f402a294ab123f46f79-small.png",
        "cover":
            "https://assets.website-files.com/602feca01bf76a06da0f87a6/61ae35c1bdcea9a93d596ca0_RanchPotatoSkinRS.jpg",
        "deliveryTime": "25",
        "rate": 4.4,
        "delivery_price": 10,
        "offers":[],
        "statu":"open"
      },
      {
        "id":3,
        "name": "Chatima",
        "slug": "chatima",
        "cuisines": ["Pitza", "Burgers", "Chicken"],
        "brand_logo":
            "https://hsaa.hsobjects.com/h/restaurants/logo_ars/000/023/926/9bc7ebd20ca55bf97b541fbc44aa7e06-small.jpg",
        "cover":
            "https://rs-menus-api.roocdn.com/images/fa1fed06-1afe-4e24-b763-792a16a85423/image.jpeg",
        "deliveryTime": "15-25",
        "rate": 3.4,
        "delivery_price": 0,
        "offers":[
            {
              "id":1,
              "percentage": "-40%",
              "offer": " 40% off entire menu"
            }
        ],
        "statu":"open"
      },
      {
        "id":4,
        "name": "Mr Burger",
        "slug":"MrBurger",
        "cuisines": ["Burger","Fast Food"],
        "brand_logo":
            "https://hsaa.hsobjects.com/h/restaurants/logo_ars/000/022/888/2716125147ab61dc17e15acbc53e77d0-small.jpg",
        "cover":
            "https://assets.website-files.com/602feca01bf76a06da0f87a6/61ae3f7f4b9301921cd9e4b5_NanasBBQRSZ.jpg",
        "deliveryTime": "15-30",
        "rate": 2.3,
        "delivery_price": 5,
        "offers":[
            {
              "id":1,
              "percentage": "-40%",
              "offer": " 40% off entire menu"
            }
        ],
        "statu":"closed"
      },
      {
        "id":5,
        "name": "WORTHY",
        "slug":"WORTHY",
        "cuisines": ["Sandwiches", "Italian", "Fast Food"],
        "brand_logo":"https://hsaa.hsobjects.com/h/restaurants/logos/000/029/480/710fb927419e748915322d866a1044c0-small.jpg",
        "cover":"https://rs-menus-api.roocdn.com/images/af7c03cf-3c9f-4506-bdbb-856971442187/image.jpeg?width=988.5&height=556.5&auto=webp&format=jpg",
        "deliveryTime": "35",
        "rate": 4.3,
        "delivery_price": 0,
        "offers":[
            {
              "id":1,
              "percentage": "-40%",
              "offer": " 40% off entire menu"
            }
        ],
        "statu":"open"
      },
      {
        "id":6,
        "name": "VOX Cinema",
        "slug":"VOX_Cinema",
        "cuisines": ["American", "Burgers", "Chicken"],
        "brand_logo":
            "https://hsaa.hsobjects.com/h/restaurants/logos/000/015/412/54c496057d8dce598b7d3a0130fcb358-small.jpg",
        "cover":
            "https://assets.website-files.com/602feca01bf76a06da0f87a6/61ae35c1bdcea9a93d596ca0_RanchPotatoSkinRS.jpg",
        "deliveryTime": "25",
        "rate": 4.4,
        "delivery_price": 10,
        "offers":[],
        "statu":"busy"
      },
      {
        "id":7,
        "name": "Dat pizza dough",
        "slug": "Dat_pizza_dough",
        "cuisines": ["Amiracan"],
        "brand_logo":
            "https://hsaa.hsobjects.com/h/restaurants/logos/000/025/481/fbdf4555507d37cedfa28b293bb9ab2f-small.jpg",
        "cover":
            "https://assets.website-files.com/602feca01bf76a06da0f87a6/61ae35c1bdcea9a93d596ca0_RanchPotatoSkinRS.jpg",
        "deliveryTime": "25",
        "rate": 3.3,
        "delivery_price": 0,
        "offers":[
            {
              "id":1,
              "percentage": "-40%",
              "offer": " 40% off entire menu"
            },
            {
              "id":2,
              "percentage": "-10%",
              "offer": " -10% first order"
            }
        ],
        "statu":"open"
      },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
        child: Icon(Icons.arrow_back,color: Colors.black)),
        elevation: 0.6,
        title: Text('${widget.CategorieName}',style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,top: 15,right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('${widget.CategorieName}',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold)),
                 Padding(
                            padding: const EdgeInsets.only(right: 0,),
                            child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: Color.fromARGB(255, 230, 230, 230)
                              )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                   width(5),
                                  GestureDetector(
                                    onTap: (){
                                       setState(() {
                                        islist = true;
                                       });
                                    },
                                    child: Container(
                                      child: Icon(Icons.monitor_rounded,size: 20,color:islist==false?Color.fromARGB(255, 230, 230, 230):Colors.red,)),
                                  ),
                                  width(10),
                                  Container(
                                    height: 15,
                                    width: 0.4,
                                    color: Color.fromARGB(255, 184, 184, 184),
                                  ),
                                  width(10),
                                  GestureDetector(
                                     onTap: (){
                                       setState(() {
                                        islist = false;
                                       });
                                    },
                                    child: Icon(Icons.list_rounded,size: 23,color:islist!=false?Color.fromARGB(255, 230, 230, 230):AppColor,),
                                  ),
                                  width(5),
                                ],
                              ),
                            ),
                          )
               ],
             ),
             height(5),
             Text('137 resturant',style: TextStyle(color: Color.fromARGB(255, 179, 179, 179),fontSize: 10,fontWeight: FontWeight.w400)),
             height(10),
            islist==false? ListView.builder(
              physics: NeverScrollableScrollPhysics(),
               shrinkWrap: true,
               itemCount: CategoryRestaurant.length,
               itemBuilder: (context,index){
               return  StoreList(Restaurant: CategoryRestaurant[index],id:CategoryRestaurant[index]['id'],);
             }): ListView.builder(
               physics: NeverScrollableScrollPhysics(),
               shrinkWrap: true,
               itemCount: CategoryRestaurant.length,
               itemBuilder: (context,index){
               return  Padding(
                padding: const EdgeInsets.only(left: 1,bottom: 10),
                child: StoreGridl(Restaurant: CategoryRestaurant[index],id:CategoryRestaurant[index]['id'],size: 140.0,),
               );
             }),
            ],
          ),
        ),
      ),
    );
  }
}


