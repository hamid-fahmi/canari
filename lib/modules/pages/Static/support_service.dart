import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportService extends StatefulWidget {
  const SupportService({Key key}) : super(key: key);

  @override
  State<SupportService> createState() => _SupportServiceState();
}

class _SupportServiceState extends State<SupportService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/support.png',height: 200,width:200,),
            height(30),
            Padding(
              padding: const EdgeInsets.only(left:25,right:25),
              child: Text(DemoLocalization.of(context).getTranslatedValue('support_title'),style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
              textAlign:TextAlign.center,
              ),
            ),
            Padding(
              padding:EdgeInsets.only(left: 25,right:25,top:30,bottom:20),
              child: GestureDetector(
                onTap: () async => await launch(
                    "https://wa.me/+212619157091"),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                  border: Border.all(color:AppColor,width: 1.2),
                  borderRadius: BorderRadius.circular(5)
                  ),
                  child:Padding(
                    padding: const EdgeInsets.only(left:15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                       Row(
                         children: [
                           Icon(FontAwesomeIcons.whatsapp,color: AppColor,size: 28,),
                           width(10),
                           Text(DemoLocalization.of(context).getTranslatedValue('contact_by_whatsapp')),
                         ],
                       ),
                        Icon(Icons.arrow_forward_ios,color: AppColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:EdgeInsets.only(left: 25,right:25,top:0,bottom:20),
              child:GestureDetector(
                onTap: () async => await launch(
                    "tel:+212619157091"),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color:AppColor,width: 1.2),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone_enabled_rounded,color: AppColor,size: 28,),
                            width(10),
                            Text(DemoLocalization.of(context).getTranslatedValue('contact_by_phone')),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,color: AppColor),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:EdgeInsets.only(left: 25,right:25,top:0,bottom:0),
              child: GestureDetector(
                onTap: () async => await launch(
                    "mailto:contact@canariapp.com"),
                child:Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color:AppColor,width: 1.2),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined,color: AppColor,size: 28,),
                            width(10),
                            Text(DemoLocalization.of(context).getTranslatedValue('contact_by_email')),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,color:AppColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
