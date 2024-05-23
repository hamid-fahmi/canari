import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/modules/pages/Order/checkout_page.dart';
import 'package:shopapp/shared/components/components.dart';

import '../../Layout/HomeLayout/selectAddres.dart';
import '../../Layout/shopcubit/storecubit.dart';
import '../../Layout/shopcubit/storestate.dart';
import '../../modules/pages/ProduitDetails/product_detail.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/remote/cachehelper.dart';

class MarketDetails extends StatefulWidget {
  final menus;
  final store;
  const MarketDetails({Key key, this.menus, this.store}) : super(key: key);

  @override
  State<MarketDetails> createState() => _MarketDetailsState();
}

class _MarketDetailsState extends State<MarketDetails> {
  double latitud = Cachehelper.getData(key: "latitude");
  String MyLocation = Cachehelper.getData(key: "myLocation");
  bool isSearch = false;
  List Filterdata = [];
  List list = [];
  void filterProducts(value){
    setState((){
     if(value==''){
       Filterdata = widget.menus['products'];
     }
     Filterdata = list.where((element) => element['name'].toLowerCase().contains(value.toLowerCase())).toList();
    });
  }
  // int Qty = 1;

  // addToCart({product}){
  //   if(dataService.itemsCart.length==0){
  //     setState(() {
  //       dataService.itemsCart.add({
  //         "id":product['id'],
  //         "name":product['name'],
  //         "quantity":product['quantity'],
  //         "price":product['price']
  //       });
  //     });
  //   }else{
  //     var containProduct = dataService.itemsCart.where((element) => element['id']==product['id']).toList();
  //     if(containProduct.isEmpty){
  //     setState(() {
  //       dataService.itemsCart.add({
  //         "id":product['id'],
  //         "name":product['name'],
  //         "quantity":product['quantity'],
  //         "price":product['price']
  //       });
  //     });
  //     }else{
  //       containProduct.forEach((element){
  //        setState(() {
  //          element['quantity']=element['quantity'] + 1;
  //        });
  //       });
  //
  //     }
  //   }
  // }


  removeFromCart({id}){
    dataService.itemsCart.where((element) => element['id']==id).forEach((element){
      setState(() {
        if (element['quantity'] > 1) {
          element['quantity']=element['quantity'] - 1;
        }
      });
    });
  }

bool isExited = false;
var price ;

  getAllProducts(categories) {
    var products = [];
    for (var category in categories) {
      for (var product in category['products']) {
        products.add(product);
      }
    }
    return products;
  }
   AddQtytoList(){
    widget.menus['products'].forEach((e){
      e['quantity']=1;
    });
  }
  @override
  void initState() {
    AddQtytoList();
    list = Filterdata = widget.menus['products'];
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return BlocProvider(
      create: (BuildContext context) => StoreCubit(),
      child: BlocConsumer<StoreCubit,ShopStates>(
       listener: (context,state){},
        builder: (context,state){
          var cubit = StoreCubit.get(context);

          List<dynamic> OfferProducts = [];
          if(cubit.store!=null){
            if(cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length > 0){

              var productsid = cubit.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'];
              printFullText(productsid.toString());

              var allProducts = getAllProducts(cubit.store['menus']);
              for (dynamic id in productsid){
                allProducts.forEach((product){
                  if (product['id'] == id['id'] && OfferProducts.where((element) => element['id']==product['id']).toList().length==0){
                    OfferProducts.add(product);
                  }
                });
              }
            }

          }
         return Scaffold(
           bottomNavigationBar:dataService.itemsCart.length>0?Container(
             decoration: BoxDecoration(
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                       color: Colors.grey,
                       blurRadius: 2,
                       spreadRadius: 1,
                       offset: Offset(0, 1))
                 ]),
             height: 75,
             child: Padding(
               padding: const EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 10),
               child: GestureDetector(
                 onTap:() async {
                   if(widget.store['is_open']){
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content:Text(
                         DemoLocalization.of(context).getTranslatedValue('Vous_avez_commandé_dans_un_restaurant_fermé'),
                         style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.bold),
                       ),
                       duration: Duration(milliseconds: 2000),
                     ));
                     dataService.itemsCart.clear();
                     setState(() {

                     });
                   } else {
                     if (latitud != null){
                       var totalPrice = await navigateTo(
                           context,CheckoutPage(
                         rout:'grocery',
                         paymentMethods:widget.store['payment_methods'],
                         service_fee:widget.store['service_fee'],
                         delivery_price:widget.store['delivery_price'],
                         olddelivery_price:widget.store['delivery_price_old'],
                         store:widget.store,
                       ));
                       setState(() {
                         totalPrice = price;
                       });
                     } else {
                       final changeAdress = await navigateTo(
                           context,
                           SelectAddres(
                             routing: 'restaurantPage',
                             paymentMethods:widget.store['payment_methods'],
                             service_fee:widget.store['service_fee'],
                             delivery_price:widget.store['delivery_price'],
                             olddelivery_price:widget.store['delivery_price_old'],
                             store:widget.store,
                           ));
                       setState(() {
                         if (changeAdress != null) {
                           MyLocation = changeAdress;
                         }
                       });
                     }
                   }

                 },

                 child: Container(
                   height: 50,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5),
                     color: Colors.red,
                   ),
                   width: double.infinity,
                   child: Padding(
                     padding: const EdgeInsets.only(left: 15,right: 15),
                     child: Row(
                       mainAxisAlignment:
                       MainAxisAlignment.spaceBetween,
                       children: [
                         Padding(
                           padding: const EdgeInsets.only(right: 15),
                           child: Row(
                             children: [
                               Container(
                                   height: 35,
                                   width: 35,
                                   decoration: BoxDecoration(
                                     borderRadius:BorderRadius.circular(5),
                                     color:dataService.itemsCart.length == 0 ? Color.fromARGB(255, 253, 143, 135) : Color.fromARGB(255, 253, 106, 95),
                                   ),
                                   child: Center(
                                       child: Text(
                                         '${dataService.itemsCart.length}',
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                             fontSize: 17,
                                             color: Colors.white,
                                             fontWeight:
                                             FontWeight.bold),
                                       ))),
                               width(10),
                               Text(
                                 'رؤية طلب',
                                 style: TextStyle(
                                     fontWeight:
                                     FontWeight.w500,
                                     fontSize: 17,
                                     color: Colors.white),
                               )
                             ],
                           ),
                         ),
                         Text(
                           '  ${cubit.getTotalPrice()} درهم ',
                           style: TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 17,
                               color: Colors.white),
                         )
                       ],
                     ),
                   ),
                 ),
               ),
             ),
           ):height(0),
           backgroundColor:Colors.white,
           appBar:AppBar(
             elevation:0,
             leading:GestureDetector(
                 onTap: ()async{
                 var totalPrice = await Navigator.of(context).pop();
                 setState((){
                   totalPrice=price;
                 });
                 print(price);

                 },
                 child: Icon(Icons.arrow_back,color: Colors.black)),
             actions: [
               Padding(
                 padding: const EdgeInsets.only(right: 20,left: 20),
                 child:isSearch == false?
                 GestureDetector(
                     onTap: (){
                       setState(() {
                         isSearch = true;
                       });
                     },
                     child: Icon(Icons.search,color: Colors.black,)):GestureDetector(
                     onTap: (){
                       setState(() {
                         isSearch = false;
                         Filterdata = list;
                       });
                     },
                     child:isSearch == false? Icon(Icons.search,color: Colors.black,):Icon(Icons.close,color: Colors.black,)),
               )
             ],
             title:isSearch == false?Text('${widget.menus['name']}',style: TextStyle(fontSize:16,color:Colors.black,fontWeight: FontWeight.bold)):TextField(
               decoration: InputDecoration(
                   hintText: DemoLocalization.of(context).getTranslatedValue('search_produit')
               ),
               autofocus:true,
               onChanged: (value){
                 filterProducts(value);
               },
             ),
             backgroundColor: Colors.white,
           ),
           body:SingleChildScrollView(
             physics: BouncingScrollPhysics(),
             child: Align(
               alignment:Alignment.topRight,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children:[

                     GridView.builder(
                       shrinkWrap:true,
                       physics: NeverScrollableScrollPhysics(),
                       itemCount:Filterdata.length,
                       itemBuilder: (BuildContext context, index){
                         StoreName = widget.store['name'];
                         StoreId = widget.store['id'];
                         deliveryPrice = widget.store['delivery_price'];
                         storeStatus = widget.store['is_open'];
                         var product = Filterdata[index];
                         var contain = dataService.itemsCart.where((element) =>
                         element['id'] == product['id']).toList();
                         if (contain.isEmpty){
                           isExited = false;
                         }else{
                           isExited = true;
                         }
                         return
                           Padding(
                           padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom:10),
                           child: Container(
                             child:Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisAlignment:MainAxisAlignment.start,
                               children:[
                                 InkWell(
                                   onTap:()async{
                                     if(product['modifierGroups'].length==0) {
                                       var totalPrice = await showModalBottomSheet(
                                           shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                           ),
                                           isScrollControlled: true,
                                           context: context,
                                           builder: (context) {
                                             StoreName =widget.store['name'];
                                             StoreId = widget.store['id'];
                                             deliveryPrice = widget.store['delivery_price'];
                                             storeStatus = widget.store['is_open'];
                                             cubit.qty = 1;
                                             return buildProduct(
                                               product,
                                               cubit,
                                               StoreName,
                                               StoreId,
                                               deliveryPrice,
                                               storeStatus,
                                               offers:widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                             );
                                           });
                                       setState(() {
                                         totalPrice = price;
                                       });
                                     }
                                     else{
                                       StoreName = widget.store['name'];
                                       StoreId = widget.store['id'];
                                       deliveryPrice =widget.store['delivery_price'];
                                       olddeliveryPrice = widget.store['delivery_old_price'];
                                       storeStatus = widget.store['is_open'];
                                       var totalPrice = await navigateTo(context,ProductDetail(
                                           id:StoreId,
                                           StoreName:StoreName,
                                           DeliveryPrice:deliveryPrice,
                                           dishes: product,
                                           storeStatus: storeStatus,
                                           offer:widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                           prixOffer:widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder' && e['type'] != 'freeDelivery').toList()[0]['products'].where((element)=>element['id']==product['id']).toList()[0]['sale_price']:null:null
                                       ));
                                       setState(() {
                                         totalPrice = price;
                                       });
                                     }
                                   },
                                   child: Padding(
                                     padding: const EdgeInsets.all(4.0),
                                     child: Container(
                                       child:product['image']!=''?ClipRRect(
                                         borderRadius:BorderRadius.circular(7),
                                         child:Padding(
                                           padding:const EdgeInsets.all(8.0),
                                           child:CachedNetworkImage(
                                               imageUrl:"${product['image']}",
                                               placeholder: (context, url) =>
                                                   ClipRRect(
                                                       borderRadius:BorderRadius.circular(7),
                                                       child: Image.asset('assets/placeholder.png',fit:BoxFit.cover,)),
                                               errorWidget: (context, url, error) => ClipRRect(
                                                   borderRadius:BorderRadius.circular(7),
                                                   child: Image.asset('assets/placeholder.png',fit:BoxFit.cover,)),
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
                                       )
                                           :ClipRRect(
                                           borderRadius:BorderRadius.circular(7),
                                           child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
                                       height: 150,
                                       width: 150,
                                       decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(7),
                                           border: Border.all(color: Colors.grey[300],width: 0.5)
                                       ),
                                     ),
                                   ),
                                 ),
                                 height(5),
                                 Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style:TextStyle(
                                   fontWeight: FontWeight.bold,fontSize: 13.5,
                                 ),),
                                 height(5),
                                 Text('${product['name']}',style: TextStyle(
                                     fontWeight: FontWeight.w400,fontSize: 13.5,
                                     overflow:TextOverflow.ellipsis,
                                     color: Colors.grey[500]
                                 ),maxLines:2,textAlign: TextAlign.center,
                                 ),
                                 // height(5),
                                 isExited?
                                 Padding(
                                   padding: const EdgeInsets.only(left: 0,right: 0,bottom: 15,top: 5),
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       color: Colors.white,
                                       boxShadow: [
                                         BoxShadow(
                                             color: Colors.grey[200],
                                             offset: Offset(1,2),
                                             spreadRadius: 1,
                                             blurRadius: 1
                                         )
                                       ],
                                     ),
                                     height:40,
                                     child: Row(
                                       crossAxisAlignment: CrossAxisAlignment.center,
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children:[
                                         TextButton(
                                           onPressed: (){
                                             print(widget.store['id']);
                                             print(product['id']);
                                             setState(() {
                                               cubit.addToCart(
                                                 product:product,
                                                 attributes: [],
                                                 storeName:widget.store['name'],
                                                 storeStats:widget.store['is_open'],
                                                 productStoreId:widget.store['id'],
                                                 productId:product['id'],
                                                 Qty:cubit.qty,
                                                 offers:widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                                 prixOffer:null,
                                               );
                                             });
                                           }, child:Icon(Icons.add,color: Colors.red,size: 22),

                                         ),
                                         width(5),
                                         Text('${contain[0]['quantity']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                                         width(5),
                                         contain[0]['quantity']==1?TextButton(onPressed: (){
                                           setState(() {
                                             dataService.itemsCart.removeWhere((element) => element['id']==product['id']);
                                           });
                                         },child:Icon(Icons.delete,color: Colors.red,size: 22)):TextButton(onPressed: (){
                                           removeFromCart(id:product['id']);
                                         },child:Icon(Icons.remove,color: Colors.red,size: 22)),
                                       ],
                                     ),
                                   ),
                                 ):
                                 Padding(
                                   padding: const EdgeInsets.only(top:10,right: 0,),
                                   child:Align(
                                     child: Container(
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(8),
                                         color: Colors.white,
                                         boxShadow: [
                                           BoxShadow(
                                               color: Colors.grey[200],
                                               offset: Offset(1,2),
                                               spreadRadius: 1,
                                               blurRadius: 1
                                           )
                                         ],
                                       ),
                                       height:40,width:40,child:IconButton(
                                         onPressed: (){
                                           setState(() {
                                             cubit.addToCart(
                                               product:product,
                                               attributes: [],
                                               storeName:widget.store['name'],
                                               storeStats:widget.store['is_open'],
                                               productStoreId:widget.store['id'],
                                               productId:product['id'],
                                               Qty:cubit.qty,
                                               offers:widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList().length>0?widget.store['offers'].where((e)=>e['type'] != 'freeDeliveryFirstOrder').toList()[0]:null,
                                               prixOffer:null,
                                             );
                                           });
                                         },icon:Icon(Icons.add,size: 22)),
                                     ),
                                     alignment: Alignment.center,
                                   ),
                                 )
                               ],
                             ),
                           )
                         );
                       },
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 2,
                         crossAxisSpacing: 0.0,
                         childAspectRatio: 1/1.59,
                         mainAxisSpacing: 0.0,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         );
        },
      ),
    );
  }
  Widget buildProduct(product,cubit,StoreName,StoreId,deliveryPrice,storeStatus,{dynamic prixOffer,offers}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            product['image']!=''? Container(
              height: 300,
              width: double.infinity,
              child:product['image']==''?
              Image.asset('assets/placeholder.png',):
              CachedNetworkImage(
                  imageUrl: '${product['image']}',
                  placeholder: (context, url) =>
                      Image.asset('assets/placeholder.png',fit: BoxFit.cover,),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageBuilder: (context, imageProvider){
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover
                        ),
                      ),
                    );
                  }
              ),


            ):height(0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  setState((){
                    Navigator.pop(
                        context, '${cubit.getTotalPrice()}');
                  });
                },
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close,color: Colors.black,size: 25)),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15,top: 20,right: 15),
          child: Text('${product['name']}',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
        ),
        product['description']!=null?   Padding(
          padding: const EdgeInsets.only(left: 15,top: 20,right: 15),
          child: Column(

            children: [
              Text(
                '${product['description']}',
                style:
                TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ):height(0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            prixOffer!=null? Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${product['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color:Colors.grey[400],decoration: TextDecoration.lineThrough),),
            ):height(0),
            Padding(
              padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
              child: Text('${prixOffer==null?product['price']:prixOffer} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
            ),
          ],
        ),

        height(20),
        StatefulBuilder(builder: (context,setState){
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            height: 75,
            child: Padding(
              padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 10),
              child: GestureDetector(
                onTap: (){
                  StoreName = StoreName;
                  StoreId = StoreId;
                  deliveryPrice = deliveryPrice;
                  cubit.addToCart(
                      product:product,
                      Qty:cubit.qty,
                      productStoreId:StoreId,
                      attributes:[],
                      storeStats: storeStatus,
                      offers:offers,
                      storeName:StoreName,
                      prixOffer:prixOffer!=null?int.parse(prixOffer):double.parse(product['price'])
                  );
                  if(cubit.isinCart){
                    Navigator.pop(context, '${cubit.getTotalPrice()}');
                  }
                  if(cubit.isinCart==false){
                    print('${cubit.isinCart}');
                    dataService.itemsCart.clear();
                    dataService.productsCart.clear();
                    cubit.addToCart(
                        product:product,
                        Qty:cubit.qty,
                        productStoreId:StoreId,
                        attributes:[],
                        storeStats: storeStatus,
                        offers:offers,
                        storeName:StoreName,
                        prixOffer:prixOffer!=null?int.parse(prixOffer):double.parse(product['price'])
                    );
                    if(cubit.isinCart){
                      Navigator.pop(context, '${cubit.getTotalPrice()}');
                    }
                  }


                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:AppColor,
                        ),
                        width: double.infinity,
                        child: Center(child: Text(DemoLocalization.of(context).getTranslatedValue('Ajouter_au_panier'),style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
                        )
                        ),
                      ),
                    ),
                    width(5),
                    StatefulBuilder(builder: (context,setState){
                      return Expanded(
                        child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color:Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Icon(Icons.remove,color: Colors.black,size: 30,),
                                ),
                                onTap: (){
                                  cubit.minus();
                                  setState((){});
                                },
                              ),
                              width(20),
                              Text('${cubit.qty}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),),
                              width(20),
                              GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Icon(Icons.add,color: Colors.black,size: 30,),
                                ),
                                onTap: (){
                                  cubit.plus();
                                  setState((){});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
