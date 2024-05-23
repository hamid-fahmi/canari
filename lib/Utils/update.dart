import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class Update extends StatefulWidget {
  const Update({ Key key }) : super(key: key);
  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                  child: Image.asset('assets/canarilogo.jpg',height: 100)),
              SizedBox(height: 30,),
              Text('تطبيق Canari يحتاج إلى تحديث',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600, fontSize: 14),),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Text('لاستخدام هذا التطبيق، تحتاج إلى تنزيل أحدث إصدار. يرجى تحديث التطبيق الآن، لن يستغرق من وقتك سوى دقيقة',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600, fontSize: 14,height: 2),textAlign: TextAlign.center),
              ),
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:AppColor,
                  ),
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppColor,
                      ),
                      onPressed: (){
                        if(Platform.isAndroid){
                          launch("https://play.google.com/store/apps/details?id=com.canarisuper.app");
                        }
                        else if(Platform.isIOS){
                          launch("https://apps.apple.com/ma/app/canari-food-delivery/id6448685108");
                        }
                      },
                      child: Text('تحديث',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),)),
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.googlePlay,size: 20),
                SizedBox(width: 10,),
                Text('Google play',style: TextStyle(color: Color.fromARGB(255, 64, 64, 64),fontWeight: FontWeight.bold,fontSize: 15),),
                   width(20),
                Icon(FontAwesomeIcons.appStore,size: 20),
                SizedBox(width: 5,),
                Text('AppStore',style: TextStyle(color: Color.fromARGB(255, 64, 64, 64),fontWeight: FontWeight.bold,fontSize: 15),)
              ],
            ),
          )
        ],
      ),
    );
  }
}