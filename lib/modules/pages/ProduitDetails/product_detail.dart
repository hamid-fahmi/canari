
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/Layout/shopcubit/storestate.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/shared/components/constants.dart';

import '../../../shared/components/components.dart';

class ProductDetail extends StatefulWidget {
 final dishes;
 final  int id;
 final StoreName;
 final storeStatus;
 final DeliveryPrice;
 final prixOffer;
 final offer;
  const ProductDetail({ Key key,this.id, this.dishes, this.StoreName, this.DeliveryPrice, this.storeStatus, this.prixOffer, this.offer,}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<dynamic> attributes = [];
  List<dynamic> products = [];
 bool isshow = false;
    CheckMin(){
      bool allMinZero = true;
      for (var item in  widget.dishes['modifierGroups']) {
        if (item["min"] != 0) {
          allMinZero = false;
          break;
        }
      }

      if (allMinZero) {
      return  isshow = true;
      } else {
      return  isshow = false;
      }
    }

     check(){
     var checkmin = false;
     var  modifierGroups  = widget.dishes['modifierGroups'].where((e)=>e['min']!=0).toList().every((modifier){

      var contain = this.attributes.where((e) => e['id'] == modifier['id']).toList();

        if(contain.length!=0){

          checkmin = modifier['min'] <= contain[0]['products'].length;

        }
       return contain.isNotEmpty?checkmin:false;
       });
       if(modifierGroups){
           isshow =true;
       }else{
           isshow =false;
       }
    }

    totalprice(products){
      double totalPrice = 0.0;
      for (var item in products) {
        List<dynamic> itemProducts = item['products'];
        for (var product in itemProducts) {
          double price = double.tryParse(product['price']);
          totalPrice += price;
        }
      }
      return totalPrice;
    }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (BuildContext context) =>StoreCubit(),
    child: BlocConsumer<StoreCubit,ShopStates>(
      listener: (context,state){
        var cubit = StoreCubit.get(context);
        if(state is AddtoCartSucessfulState){
          Navigator.pop(context,'${state.totalprice}');
        }
        if(state is ChangevalueState){
          dataService.itemsCart.clear();
          dataService.productsCart.clear();
          cubit.addToCart(product:widget.dishes,Qty:cubit.qty,productStoreId: widget.id,attributes:attributes,storeStats:widget.storeStatus,storeName:widget.StoreName,);
        }
      },
      builder: (context,state){
       print(check());
        var cubit = StoreCubit.get(context);
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
             bottomNavigationBar:Container(
               decoration: BoxDecoration(
                  color: Colors.white,
                 boxShadow: [
                 BoxShadow(
                   color: Colors.grey[300],
                   blurRadius: 3,
                   spreadRadius: 1,
                 offset: Offset(0, 2)
                 )
               ]),
               height: 75,
               child:
               Padding(
                      padding: const EdgeInsets.only(right: 5,left: 5,bottom: 10,top: 10),
                      child: GestureDetector(
                        onTap: (){
                          StoreName = widget.StoreName;
                          StoreId = widget.id;
                          deliveryPrice = widget.DeliveryPrice;
                          CheckMin();
                          check();
                          if(isshow){
                            print(attributes);
                            cubit.addToCart(product:widget.dishes,Qty:cubit.qty,productStoreId: widget.id,attributes:attributes,storeStats: widget.storeStatus,storeName:widget.StoreName,
                            prixOffer:widget.prixOffer!=null?int.parse(widget.prixOffer):double.parse(widget.dishes['price']),offers:widget.offer,);
                            setState(() {

                            });
                          }else{
                            print('select');
                          }
                        },
                        child: Row(
                          children: [
                            width(5),
                            Expanded(
                              child: Container(
                                child:Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Icon(Icons.add,color: Colors.black,size: 30,),
                                      ),
                                      onTap: (){
                                        cubit.plus();
                                      },
                                    ),
                                    width(15),
                                    Text('${cubit.qty}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),),
                                    width(15),
                                    GestureDetector(
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color:Colors.grey[100],
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Icon(Icons.remove,color: Colors.black,size: 30,),
                                      ),
                                      onTap: (){
                                        cubit.minus();
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                            width(10),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:isshow?AppColor:Colors.grey,
                                ),
                                width: double.infinity,
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10,left: 10),
                                      child: Text(DemoLocalization.of(context).getTranslatedValue('ajout'),style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                        height: 30,
                                        width: 0.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        )

                                    ),
                                   widget.prixOffer==null?Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('${(double.tryParse(widget.dishes['price']))+totalprice(attributes)} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                    ):Padding(
                                     padding: const EdgeInsets.only(left: 10),
                                     child: Text('${(double.tryParse(widget.prixOffer))+totalprice(attributes)} درهم ',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                   ),
                                  ],
                                )
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
             ),
            body:SingleChildScrollView(
              physics:widget.dishes['modifierGroups'].length==0? NeverScrollableScrollPhysics():null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  Stack(
                  children: [
                   Container(
                        height:widget.dishes['image']==''?0:widget.dishes['modifierGroups'].length==0? 250:250,
                        width: double.infinity,
                        color:  Colors.white,
                        child:widget.dishes['image']==''?
                        height(0):
                        CachedNetworkImage(
                            imageUrl: '${widget.dishes['image']}',
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
                      Padding(
                        padding:EdgeInsets.only(top:widget.dishes['modifierGroups'].length!=0?20:40,left: 15,right: 15),
                        child:GestureDetector(
                          onTap: (){
                            setState((){
                              Navigator.pop(context,'${cubit.getTotalPrice()}');
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close,color: Colors.black,size: 25)),
                        ),
                      )
                 ],
               ),
               height(10),
               Padding(
                    padding: const EdgeInsets.only(left: 15,top: 5,right: 15),
                    child: Text('${widget.dishes['name']}',style: TextStyle(fontSize: 17.5,fontWeight: FontWeight.bold),),
                  ),
                 // height(10),
                  widget.dishes['description']!=null?Column(
                     children: [
                       Padding(
                         padding: const EdgeInsets.only(left: 15,top: 5,right: 15),
                         child: Text(
                           '${widget.dishes['description']}',
                           style:
                           TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.normal,
                               color: Colors.grey
                           ),
                         ),
                       ),
                     ],
                   ):height(0),
                  height(5),
                   widget.prixOffer==null?Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children:[
                        Padding(
                         padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
                         child: Text('${widget.dishes['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
                        ),
                     ],
                     ):Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children:[
                       Padding(
                         padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
                         child: Text('${widget.prixOffer} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(left: 15,top: 5,right: 15,bottom: 15),
                         child: Text('${widget.dishes['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal,color: Colors.black,decoration:TextDecoration.lineThrough),),
                       ),
                     ],
                   ),
                  height(5),
                  // widget.dishes['description']!=null? height(30):height(0),
              Container(
                height: 8,
                width: double.infinity,
                color: Colors.grey[100],
              ),

                  widget.dishes['modifierGroups'] != null ?  ListView.separated(
                      separatorBuilder: (context,index){
                        return Container(
                          height: 8,
                          width: double.infinity,
                          color: Colors.grey[100],
                        );
                      },
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:widget.dishes['modifierGroups'].length,
                      itemBuilder: (context,index){
                        return Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10,bottom: 15,top: 5,right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.dishes['modifierGroups'][index]['name'],
                                          style:TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight:FontWeight.bold),
                                        ),
                                        height(8),
                                        Text(' ${DemoLocalization.of(context).getTranslatedValue('Choisissez_jusqu')} ${widget.dishes['modifierGroups'][index]['max']} ',style:TextStyle(
                                          color: Color(0xFFa4a7af),
                                          fontSize: 12.5,
                                          fontWeight:FontWeight.bold,),)
                                      ],
                                    ),

                                    widget.dishes['modifierGroups'][index]['min']!=0?
                                    Text(DemoLocalization.of(context).getTranslatedValue('Requis'),style: TextStyle(
                                      color: AppColor,
                                      fontSize: 12.5,
                                      fontWeight:FontWeight.bold,
                                    ),):
                                    Text('',style: TextStyle(
                                      color: Color(0xFFa4a7af),
                                      fontSize: 12.5,
                                      fontWeight:FontWeight.w600,
                                    ),)
                                  ],
                                ),
                              ),
                              ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context,option){
                                    return Padding(
                                      padding:const EdgeInsets.only(left: 0,top: 10,bottom: 5,right: 0),
                                      child: GestureDetector(
                                        onTap: (){
                                          var myModifier = attributes.firstWhere((e) => e['id'] == widget.dishes['modifierGroups'][index]['id'],orElse: () => null);

                                          if(myModifier==null){
                                            attributes.add({
                                              "id":widget.dishes['modifierGroups'][index]['id'],
                                              "max":widget.dishes['modifierGroups'][index]['max'],
                                              "min":widget.dishes['modifierGroups'][index]['min'],
                                              "products":[widget.dishes['modifierGroups'][index]['products'][option]],
                                            });

                                            this.checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id']);

                                            CheckMin();
                                            check();
                                            setState(() {

                                            });
                                          }
                                          else{
                                            if(myModifier['products'].length == myModifier['max'] &&  (myModifier['products'].firstWhere((p) => p['id'] == widget.dishes['modifierGroups'][index]['id'],orElse: () => null))==null){
                                              this.delete(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id']);
                                              myModifier['products'].add(widget.dishes['modifierGroups'][index]['products'][option]);
                                              this.checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id']);
                                              CheckMin();
                                              check();
                                              setState(() {

                                              });
                                            }

                                            if(myModifier['products'].length < myModifier['max'] &&(myModifier['products'].firstWhere((p) => p['id'] == widget.dishes['modifierGroups'][index]['id'],orElse: () => null))==null){

                                              myModifier['products'].add(widget.dishes['modifierGroups'][index]['products'][option]);

                                              checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id']);

                                              CheckMin();
                                              check();

                                              setState(() {

                                              });
                                            }

                                            else if(myModifier['min'] != 1 && (myModifier['products'].firstWhere((p) => p['id'] == widget.dishes['modifierGroups'][index]['id'],orElse: () => null))==null){
                                              this.delete(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id']);
                                              CheckMin();
                                              check();
                                              setState(() {

                                              });
                                            }
                                          }
                                          setState((){

                                          });
                                        },
                                        child: Container(
                                          color: Colors.white,
                                          height: 45,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id'])==null?
                                                  Container(
                                                      height: 40,
                                                      width: 2.5,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(30),
                                                          bottomLeft: Radius.circular(30),
                                                        ),
                                                        color:Colors.white,
                                                      )
                                                  ):Container(
                                                      height: 40,
                                                      width: 2.5,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(30),
                                                          bottomLeft: Radius.circular(30),
                                                        ),
                                                        color:checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id'])?Colors.red:Colors.white,
                                                      )
                                                  ),

                                                  width(10),
                                                  Text('${widget.dishes['modifierGroups'][index]['products'][option]['name']}',style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,

                                                  )),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15,right: 15),
                                                child: Row(
                                                  children: [
                                                    widget.dishes['modifierGroups'][index]['products'][option]['price']!="0.00"?Text(
                                                      '+ ${widget.dishes['modifierGroups'][index]['products'][option]['price']} ${DemoLocalization.of(context).getTranslatedValue('MAD')} ',style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 13.5,
                                                        color: Colors.grey[700]
                                                    ),):Text(
                                                      '',style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                        color: Color(0xFF28c76f)
                                                    ),),
                                                    width(6),
                                                    checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id'])==null?
                                                    Container(
                                                      width: 23,
                                                      height: 23,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.transparent,
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    ):
                                                    checkModifier(widget.dishes['modifierGroups'][index]['id'],widget.dishes['modifierGroups'][index]['products'][option]['id'])?
                                                    Container(
                                                      width: 23,
                                                      height: 23,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColor,
                                                        border: Border.all(
                                                          color: AppColor,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Icon(Icons.check,size: 20,color: Colors.white),
                                                    ):
                                                    Container(
                                                      width: 23,
                                                      height: 23,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.transparent,
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context,index){
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                                      child: Container(
                                        height: 0.8,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                      ),
                                    );
                                  },
                                  itemCount: widget.dishes['modifierGroups'][index]['products'].length)

                            ],
                          ),
                        );
                      }):SizedBox(height: 0,),

                   SizedBox(height: 20,),

                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }

  void delete(id, productId) {
   var mymodifier = attributes.where((element) => element['id']==id).first;
   var product = mymodifier['products'].removeAt(0);
   setState(() {
     print('my order :${product}');
   });

  }

  checkModifier(id, productId){
  var mymodifier =attributes.firstWhere((e) => e['id'] == id,orElse: () => null);
  if(mymodifier!=null){
    var contain = mymodifier['products'].where((element) => element['id'] == productId);
    if (contain.isEmpty){
      return false;
    } else {
      return true;
    }
  }else{
    return null;
  }
  }

}