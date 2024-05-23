import 'package:buildcondition/buildcondition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/modules/Register/register.dart';
import 'package:shopapp/shared/components/constants.dart';
import '../../Layout/HomeLayout/searchStore.dart';
import '../../localization/demo_localization.dart';
import '../../modules/pages/Static/filterPage.dart';
import '../../modules/pages/Static/share.dart';
import '../../widgets/storeGridl.dart';
import '../network/remote/cachehelper.dart';

String language = Cachehelper.getData(key:"langugeCode");

void printFullText(String text) {
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

 navigateTo(context, Widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => Widget));

Widget appbar(context,{myLocation,IconData icon,Function ontap,IconData iconback,Function onback}) {
  return
    AppBar(
           backgroundColor: Colors.white,
           automaticallyImplyLeading: false,
           elevation:0,
           leading:lg!='ar'?Padding(
             padding:EdgeInsets.only(left:10,right:0),
             child:CircleAvatar(
               maxRadius: 23,
               backgroundColor:Color(0xFFf3f4f5),
               child: Center(
                 child:IconButton(onPressed:ontap,
                     icon:Icon(Icons.person,color:Color(0xFF515151),size: 20,)),
               ),
             ),
           ):Padding(
             padding:EdgeInsets.only(left:0,right:10),
             child:CircleAvatar(
               maxRadius: 23,
               backgroundColor:Color(0xFFf3f4f5),
               child: Center(
                 child:IconButton(onPressed:ontap,
                     icon:Icon(Icons.person,color:Color(0xFF515151),size: 20,)),
               ),
             ),
           ),
           actions:[
             lg!='ar'? Padding(
               padding:EdgeInsets.only(left: 0,right:10),
               child: CircleAvatar(
                 maxRadius: 23,
                 backgroundColor:Color(0xFFf3f4f5),
                 child: Center(
                   child:IconButton(onPressed:(){
                     navigateTo(context,Share());
                   },
                       icon:Icon(Icons.wallet_giftcard_sharp,color:AppColor,size: 20,)),
                 ),
               ),
             ):Padding(
               padding:EdgeInsets.only(left: 10,right:0),
               child: CircleAvatar(
                 maxRadius: 23,
                 backgroundColor:Color(0xFFf3f4f5),
                 child: Center(
                   child:IconButton(onPressed:(){
                     navigateTo(context,Share());
                   },
                       icon:Icon(Icons.wallet_giftcard_sharp,color:AppColor,size: 20,)),
                 ),
               ),
             ),
           ],
                title:GestureDetector(
                  onTap:onback,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color:Color(0xFFf3f4f5),
                    ),
                    width: double.infinity,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10,left: 10),
                                child: Icon(Icons.location_on,color: AppColor,),
                              ),
                              myLocation.length<=30? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  myLocation!=null? "${myLocation}":'اختر موقع',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ):
                              Expanded(
                                child:Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text(
                                    myLocation!=null? "${myLocation}":'اختر موقع',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),                    // Row(

                            Padding(
                              padding: const EdgeInsets.only(left: 5,right:5),
                              child: GestureDetector(
                                onTap:onback,
                                child: Icon(
                                  iconback,
                                  size: 25,
                                  color: Color.fromARGB(255, 68, 71, 71),
                                ),
                              ),
                            ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
  );
}

Widget SearchBarAndFilter(context){
    return
      Expanded(
        child: GestureDetector(
          onTap: (){
            navigateTo(context, SearchStore());
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:Color(0xFFf3f4f5),
            ),
            height: 50,
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(width: 15,),
                Icon(Icons.search,color: Color.fromARGB(255, 98, 98, 98),size: 23),
                width(5),
                Text(DemoLocalization.of(context).getTranslatedValue('search_bymeal'),style: TextStyle(
                    color: Color.fromARGB(255, 98, 98, 98)
                )),
              ],
            ),
          ),
        ),
      );
}

Widget height(
  double height,
) {
  return SizedBox(
    height: height,
  );
}

Widget width(
  double width,
) {
  return SizedBox(
    width: width,
  );
}

Widget title({@required String text,double size,Color color}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
    child: Text(
      text,
      style: TextStyle(
        color:color,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget category(context,selectFilters,Categories) {
  var cubit = StoreCubit.get(context);
  return
    Container(
      height: 110,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 15,right: 20),
        child: ListView.separated(
            separatorBuilder: (context,index){
              return width(10);
            },
            physics: BouncingScrollPhysics(),
            itemCount:Categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  navigateTo(context, FilterPage(text:Categories[index]['name'],Categories:Categories));
                  },
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Color(0xffeef2f5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Opacity(
                        opacity: 1,
                        child: CachedNetworkImage(
                            imageUrl: '${Categories[index]['image']}',
                            placeholder: (context, url) => ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
                            errorWidget: (context, url, error) =>ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.asset('assets/placeholder.png',fit: BoxFit.cover,)),
                            imageBuilder: (context, imageProvider){
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover

                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                    height(6),
                    Text('${Categories[index]['name']}',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                    )),
                  ],
                ),

              );
            }),
      ));
}



Widget CartItem(int index, StoreCubit cubit,{Function remove,add,double padding}){

  return Padding(
    padding: EdgeInsets.only(left: padding,right: padding,bottom: 10),
    child: Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('${dataService.itemsCart[index]['name']}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500
                    ),),
                  height(6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('${double.parse(dataService.itemsCart[index]['price']) * (dataService.itemsCart[index]['quantity'])} MAD',style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12
                      ),),
                      // Row(
                      //   children: [
                      //     ...dataService.itemsCart[index]['attributes'].map((e){
                      //      return Row(
                      //        children: [
                      //
                      //          Text('${e['name']}',style: TextStyle(
                      //              fontWeight: FontWeight.w500,
                      //              fontSize: 11.5,
                      //              color:Color(0xffa3aab5),
                      //
                      //          ),),
                      //          width(3),
                      //          e == dataService.itemsCart[index]['attributes'].last?Text(''):Text(',',style: TextStyle(
                      //            color:Color(0xffa3aab5),
                      //          ),),
                      //          width(3),
                      //        ],
                      //      );
                      //     }),
                      //
                      //   ],
                      // ),

                    ],
                  ),
                ],
              ),Container(
                height: 35,
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(
                        onTap:remove,
                        child: CircleAvatar(
                          maxRadius: 14,
                          backgroundColor: Colors.red,
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: 13,
                              child: Icon(Icons.remove,size: 20,color: AppColor,)),
                        )),
                    SizedBox(width: 8,),
                    Text(
                      '${dataService.itemsCart[index]['quantity']}',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8,),
                    GestureDetector(
                        onTap:add,
                        child: CircleAvatar(
                          maxRadius: 14,
                          backgroundColor: Colors.red,
                          child: CircleAvatar(
                              maxRadius: 13,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.add,size: 20,color: AppColor,)),
                        ))
                  ],
                ),
              ),
            ],
          ),
          height(5),
          Wrap(
            children: [
              ...dataService.itemsCart[index]['attributes'].map((e){
               return Row(
                 children: [
                   Text('${e['name']}',style: TextStyle(
                     fontWeight: FontWeight.w500,
                     fontSize: 11.5,
                     color:Color(0xffa3aab5),
                   ),),
                 ],
               );
              }),

            ],
          ),

        ],
      ),
    ),
  );
}

Widget Summary(BuildContext context,StoreCubit cubit,{Function ontap,String rout,isloading, bool isAccpted}){
  return Container(
    height: 80,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow:[
          BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 3),
              spreadRadius: 1,
              color: Colors.grey[350]
          )
        ]
    ),

    child: Padding(
      padding: const EdgeInsets.only(left: 20,top: 12,right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap:StoreCubit.get(context).isloading?isloading?ontap:(){
              print('object');
            }:(){
              print('object');
            },
            child:isAccpted?Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:isloading?AppColor:Colors.grey[200]
                ),
                height: 55,
                width: double.infinity,
                child:
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child:isloading?
                  Text('${rout}',style: TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),):
                  CircleAvatar(
                    maxRadius: 16,
                      backgroundColor:isloading?AppColor:Colors.grey[200],
                      child: CircularProgressIndicator(color:isloading?AppColor:AppColor,strokeWidth: 3.3,))),
                )
            ):Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:Colors.grey[200]
                ),
                height: 55,
                width: double.infinity,
                child:
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child: Text('${rout}',style: TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),)
                ),
                )
            ),
          ),
          height(10),
        ],
      ),
    ),
  );
}


Widget buildForm({
  Key fromkey,
  TextEditingController FirstnameController,
  TextEditingController LastnameController,
  Function ontap,
  Function onpress,
  String phoneCode,
  String phoneNumber,
  bool isloading
}){
  return
    Form(
    key: fromkey,
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sign Up to Canari',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          height(20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: buildTextFiled(
              controller: FirstnameController,
              keyboardType: TextInputType.name,
              hintText: 'First name',
              valid: 'first name',
            ),
          ),

          height(15),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: buildTextFiled(
              controller: LastnameController,
              valid: 'last name',
              keyboardType: TextInputType.name,
              hintText: 'Last name',
            ),
          ),
          height(15),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColor,
                            width: 2)),
                    child: CountryListPick(
                        theme: CountryTheme(
                          initialSelection:
                          'Choisir un pays',
                          labelColor: AppColor,
                          alphabetTextColor:
                          AppColor,
                          alphabetSelectedTextColor:
                          Colors.red,
                          alphabetSelectedBackgroundColor:
                          Colors.grey[300],
                          isShowFlag: false,
                          isShowTitle: false,
                          isShowCode: true,
                          isDownIcon: false,
                          showEnglishName: true,
                        ),
                        appBar: AppBar(
                          backgroundColor:
                          AppColor,
                          title:
                          Text('Choisir un pays',
                            style: TextStyle(color: Colors.white),),
                        ),
                        initialSelection: '+212',
                        onChanged: (CountryCode code) {
                          print(code.name);
                          print(code.dialCode);
                          phoneCode = code.dialCode;
                        },
                        useUiOverlay: false,
                        useSafeArea: false),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  flex: 3,
                  child: buildTextFiled(
                      keyboardType: TextInputType.number,
                      hintText: 'Number',
                      valid: 'Number',
                      onSaved: (number) {
                        if (number.length == 9) {
                          phoneNumber = "${phoneCode}${number}";
                        } else {
                          final replaced = number.replaceFirst(
                              RegExp('0'), '');
                          phoneNumber = "${phoneCode}${replaced}";
                          print(phoneNumber);
                        }
                      }
                  ),
                ),
              ],
            ),
          ),
          height(15),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: GestureDetector(
              onTap:ontap,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColor
                ),
                child: Center(
                    child: isloading ? Text('Next',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ) : CircularProgressIndicator(color: Colors.white)),
                height: 58,
                width: double.infinity,
              ),
            ),
          ),
          height(6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('I have an account !'),
              TextButton(onPressed:onpress,
                  child: Text('Login', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),))
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildButton({bool ishow,Function ontap}){
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 1)
          )
        ]),
    height: 75,
    child: Padding(
      padding: const EdgeInsets.only(right: 15,left: 15,bottom: 10,top: 10),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:ishow?AppColor:Colors.grey,
          ),
          width: double.infinity,
          child: Center(child: Text('أضف إلى السلة',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)),
        ),
      ),
    ),
  );
}


Widget buildStores(bool isloading, List stores,ispriceLoading,List PriceDeliverys){
  return BuildCondition(
    condition:isloading,
    builder: (context){
      final newStores = stores;
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 0),
        child: Container(
          height: 190,
          color: Colors.white,
          width: double.infinity,
          child:ListView.builder(
              scrollDirection:Axis.horizontal,
              itemCount:newStores.length,
              shrinkWrap:true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index){
                return Padding(
                  padding:EdgeInsets.only(left: 0,right: 10,bottom: 0),
                  child: StoreGridl(Restaurant:newStores[index],id:newStores[index]['id'],size: 140.0,ispriceLoading:ispriceLoading,PriceDeliverys:PriceDeliverys),
                );
              }),
        ),
      );
    },
    fallback: (context){
      return
        Padding(
          padding:EdgeInsets.only(left: 0,right: 15,bottom: 0,top: 5),
          child: Container(
            height: 220,
            color: Colors.white,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return width(10);
              },
              physics: BouncingScrollPhysics(),
              itemCount:7,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){},
                  child: Container(
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
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 105, left: 120, right: 10),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  period: Duration(seconds: 2),
                                  highlightColor: Colors.grey[100],
                                  child: Container(
                                    height: 35,
                                    child: Center(
                                        child: Text(
                                          '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),

                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey[200], offset: Offset(0, 1))
                                        ]),
                                  ),
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
                                        'Free Delivery',
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
                  ),
                );
              },
            ),
          ),
        );
    },
  );
}


buildNoNetwork(){
  return Container(
    height:50,
    width: double.infinity,
    color:AppColor,
    child: Padding(
      padding: const EdgeInsets.only(top: 0,right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('أنت غير متصل بالانترنت',style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),),
          width(6),
          Icon(Icons.network_check,color: Colors.white,)
        ],
      ),
    ),
  );

}
Widget ValideIcon(isValid){
  if(isValid == true){
    return Icon(Icons.check_circle_outline,size: 25,color: Colors.green,);
  }if(isValid == false){
    return Icon(Icons.info_outline,size: 25,color: Colors.red,);
  }else{
    return SizedBox(height: 0,);
  }
}
Widget Rate(rate_count,Restaurant){
  if (rate_count > 20) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('(',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
        ),),
        Text('20',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
        ),),
        Padding(
          padding: const EdgeInsets.only(top: 0,bottom: 2),
          child: Container(height: 13,width: 10,color: Colors.white,child: Center(
            child: Text('+',style: TextStyle(
                color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold
            ),
              textAlign: TextAlign.center,
            ),
          ),),
        ),
        Text(')',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
        ),),
      ],
    );
  } else if(rate_count > 10){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('(',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
        ),),
        Text('+',style: TextStyle(
            color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold
        ),
          textAlign: TextAlign.center,
        ),
        Text('10',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.5?Colors.green:Colors.grey,
        ),),

        Text(')',style: TextStyle(
          fontSize: 10,
          color:Restaurant['rate']>=3.0?Colors.green:Colors.grey,
        ),),
      ],
    );
  } else {
    return Text(rate_count<10?"":'${rate_count}');
  }
}
