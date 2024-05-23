import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopapp/Layout/shopcubit/storecubit.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:intl/intl.dart';
import '../../../Layout/shopcubit/storestate.dart';
import 'dart:ui' as ui;

class CoupondPage extends StatefulWidget {
  const CoupondPage({Key key}) : super(key: key);

  @override
  State<CoupondPage> createState() => _CoupondPageState();
}

class _CoupondPageState extends State<CoupondPage> {
  String formatDate(DateTime date) {
    // Month names in Arabic
    List<String> monthNames = [
      "",
      "يناير",
      "فبراير",
      "مارس",
      "أبريل",
      "مايو",
      "يونيو",
      "يوليو",
      "أغسطس",
      "سبتمبر",
      "أكتوبر",
      "نوفمبر",
      "ديسمبر",
    ];

    // Format the date according to the required pattern
    String formattedDate =
        "${date.day} ${monthNames[date.month]} ${date.year} ";

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StoreCubit()..GetCoupons(),
      child: BlocConsumer<StoreCubit, ShopStates>(
        listener: (context, state){},
        builder: (context, state){
          var cubit = StoreCubit.get(context);
          cubit.coupons.sort((a, b) {
            return a["status"].compareTo(b["status"]);
          });
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: Text('كوبوناتي',
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.black, fontWeight: FontWeight.bold),),
            ),
            body: cubit.isCouponLoading?SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cubit.coupons.length,
                      itemBuilder: (context,index){
                        DateTime date = DateTime.parse(cubit.coupons[index]['to']);
                        String formattedDate = formatDate(date);

                        print(formattedDate);
                        return Padding(
                          padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                          child: Container(
                            height:110,
                            width:double.infinity,
                            decoration: BoxDecoration(
                                color:Colors.white,
                                border: Border.all(
                                    width: 1,
                                    color:Colors.grey[300]
                                ),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12,right: 12,top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('احصل على كوبون ${cubit.coupons[index]['label']}',style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,

                                        ),),
                                        height(10),
                                        Row(
                                          children: [
                                            Text('كود كوبون : ',style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w400,

                                            ),),
                                            Text('${cubit.coupons[index]['code']}',style: TextStyle(
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 13
                                            ),),
                                            width(5),
                                            cubit.coupons[index]['status']=='Available'?  Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: Color(0xfff81038),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text('جديد',style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11.5
                                                  ),),
                                                )):height(0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: ui.TextDirection.ltr,
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 20,
                                            width: 10,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.only(
                                                      topRight: Radius
                                                          .circular(10),
                                                      bottomRight:
                                                      Radius.circular(
                                                          10)),
                                                  color: Colors.grey[200]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  return Flex(
                                                    children: List.generate(
                                                        (constraints.constrainWidth() /
                                                            10)
                                                            .floor(),
                                                            (index) => SizedBox(
                                                          height: 1,
                                                          width: 8,
                                                          child:
                                                          DecoratedBox(
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[300]),
                                                          ),
                                                        )),
                                                    direction:
                                                    Axis.horizontal,
                                                    mainAxisSize:
                                                    MainAxisSize.max,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                            width: 10,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(10),
                                                    bottomLeft:
                                                    Radius.circular(10),
                                                  ),
                                                  color: Colors.grey[200]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      cubit.coupons[index]['status']=='Available'? Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(' صالح الى غاية ${formattedDate}',style: TextStyle(
                                              fontSize: 12.5
                                          ),),
                                      ):Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                          child: Text('تم انتهاء صلاحية هذا كوبون',style: TextStyle(
                                          fontSize: 12.5
                                      ),),
                                        ),
                                        GestureDetector(
                                            onTap: ()async{
                                              if(cubit.coupons[index]['status']=='Available'){
                                                ClipboardData data = ClipboardData(text: '${cubit.coupons[index]['code']}');
                                                await Clipboard.setData(data);
                                              }
                                            },
                                            child:cubit.coupons[index]['status']=='Available'? Text('نسخ كود كوبون',style: TextStyle(
                                              color:cubit.coupons[index]['status']=='Available'? AppColor:Colors.grey,
                                              fontWeight:cubit.coupons[index]['status']=='Available'? FontWeight.bold:FontWeight.w500,

                                            ),):height(0))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                          ),
                        );
                      })






                ],
              ),
            ):Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator(color: AppColor,))
              ],
            ),
          );
        },

      ),
    );
  }
}
