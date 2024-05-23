import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/shared/components/components.dart';

import '../../../Layout/shopcubit/storecubit.dart';
import '../../../Layout/shopcubit/storestate.dart';
import '../../../shared/components/constants.dart';

class ProductDetailsShort extends StatefulWidget {
  const ProductDetailsShort({

    Key key,
    @required this.cubit,

    this.product,
    this.storeStatus,
  }) : super(key: key);

  final StoreCubit cubit;
  final product;
  final storeStatus;

  @override
  State<ProductDetailsShort> createState() => _ProductDetailsShortState();
}

class _ProductDetailsShortState extends State<ProductDetailsShort> {
  @override
  Widget build(BuildContext context) {
    print(widget.storeStatus);
    return BlocProvider(
      create: (BuildContext context) => StoreCubit(),
      child: BlocConsumer<StoreCubit, ShopStates>(
        listener: (context,state){
          if(state is AddtoCartSucessfulState){
            Navigator.pop(context,'${state.totalprice}');
          }
          if(state is ChangevalueState){
            dataService.itemsCart.clear();
            dataService.productsCart.clear();
            widget.cubit.addToCart(product:widget.product,Qty:widget.cubit.qty,productStoreId: StoreId,attributes:[],storeStats: widget.storeStatus,storeName:StoreName,);
          }
        },
        builder: (context,state){
          return Container(
            height: 500,
            child:Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: CachedNetworkImage(
                        imageUrl: '${widget.product['image']}',
                        placeholder: (context, url) =>
                            Image.network('https://www.happyeater.com/images/default-food-image.jpg',fit: BoxFit.cover),
                        errorWidget: (context, url, error) =>Image.network('https://www.happyeater.com/images/default-food-image.jpg',fit: BoxFit.cover),
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
                    height: 220,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,top: 17,right: 15),
                    child: Text('${widget.product['name']}',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15,top: 5,right: 15),
                    child: Text(widget.product['description']==null?'':
                    '${widget.product['description']}',
                      style:
                      TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15,top: 5,right: 15),
                        child: Text('${widget.product['price']} درهم ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),),
                      ),
                    ],
                  ),
                  height(22),
                  Container(
                    child:Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        GestureDetector(
                          child: CircleAvatar(
                            backgroundColor:Colors.grey[100],
                            maxRadius: 30,
                            child: Icon(Icons.add,color: Colors.black,size: 30,),
                          ),
                          onTap: (){
                            widget.cubit.plus();
                            setState(() {

                            });
                          },
                        ),
                        width(10),
                        Text('${widget.cubit.qty}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),),
                        width(10),
                        GestureDetector(
                          child: CircleAvatar(
                            backgroundColor:Colors.grey[100],
                            maxRadius: 30,
                            child: Icon(Icons.remove,color: Color.fromARGB(255, 255, 133, 135),size: 30,),
                          ),
                          onTap: (){
                            widget.cubit.minus();
                            setState(() {

                            });
                          },
                        )
                      ],
                    ),
                  ),
                  height(15),
                  Padding(
                    padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 5),
                    child: GestureDetector(
                      onTap: (){
                        StoreName = widget.cubit.store['name'];
                        StoreId = widget.cubit.store['id'];
                        deliveryPrice = widget.cubit.store['delivery_price_old'];
                        var cantainStore = dataService.itemsCart.where((element) => element['productStoreId']==StoreId).toList();
                        print(cantainStore);
                        widget.cubit.addToCart(product:widget.product,Qty:widget.cubit.qty,productStoreId: StoreId,attributes:[],storeStats: widget.storeStatus);
                        setState(() {

                        });
                        },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:Colors.red,
                        ),
                        width: double.infinity,
                        child: Center(child: Text('أضف إلى السلة',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
                        )
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },

      ),
    );
  }
}