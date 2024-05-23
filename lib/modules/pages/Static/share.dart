import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopapp/Utils/dynamic_link.dart';
import 'package:shopapp/localization/demo_localization.dart';
import 'package:shopapp/shared/components/components.dart';

import '../../../shared/components/constants.dart';
import '../../../shared/network/remote/cachehelper.dart';

class Share extends StatefulWidget {
  const Share({Key key}) : super(key: key);

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String invitation_code = Cachehelper.getData(key: "codeInvitation");
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          DemoLocalization.of(context).getTranslatedValue('share_and_earn'),
          style: TextStyle(
              fontSize: 17,
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          height(30),
          Image.asset('assets/earn.png',height:200,width:200),
          height(30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(DemoLocalization.of(context).getTranslatedValue('share_and_earn_title'),style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
              textAlign: TextAlign.center,
            ),
          ),
          height(50),
          Padding(
            padding: const EdgeInsets.only(left: 50,right: 50),
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300],width: 1),
              borderRadius: BorderRadius.circular(8)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10,right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    invitation_code!=null?SelectableText(
                  "${invitation_code}",
                  style:TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),):SpinKitThreeBounce(
                        color: Colors.grey[400],
                        size: 20.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColor,
                    ),
                    child:Center(child: IconButton(
                        splashRadius: 25,
                        onPressed: ()async{
                          DynamicLinkProvider().createLink('${invitation_code}').then((value) {
                                    FlutterShare.share(
                                        title: 'شارك تطبيق وحصل على توصيل مجاني',
                                      text: ' \nاحصل على توصيل مجاني عن طريق مشاركة التطبيق مع 3 أصدقائك لي يحصلو اصدقائك على توصيل مجاني ايضا, كود دعوة: *${invitation_code}*',
                                        linkUrl:value,
                                    );
                                  });
                          ClipboardData data = ClipboardData(text: '${invitation_code}');
                            await Clipboard.setData(data);
                        }, icon:Icon(Icons.copy,color: Colors.white,size: 20,))),
                    height: 35,width: 70,
                  )
                  ],
                ),
              ),
            ),
          ),
          height(40),
          Padding(
            padding: const EdgeInsets.only(left: 30,right: 30),
            child: Text(DemoLocalization.of(context).getTranslatedValue('share_and_earn_description'),style: TextStyle(
              fontSize: 15,
              height: 2,
              fontWeight: FontWeight.bold,
              color: Color(0xff717f8c)
            ),textAlign: TextAlign.center,),
          ),
          
          Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 50,left: 35,right: 35),
            child: Container(
              height: 55,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16), // Optional margin for spacing
              child: MaterialButton(
                onPressed: () async{
                  DynamicLinkProvider().createLink('${invitation_code}').then((value) {
                    FlutterShare.share(
                      title: 'شارك تطبيق وحصل على توصيل مجاني',
                      text: ' \nاحصل على توصيل مجاني عن طريق مشاركة التطبيق مع 3 أصدقائك لي يحصلو اصدقائك على توصيل مجاني ايضا, كود دعوة: *${invitation_code}*',
                      linkUrl:value,
                    );
                  });
                  ClipboardData data = ClipboardData(text: '${invitation_code}');
                  await Clipboard.setData(data);
                },
                child: Text(
                  DemoLocalization.of(context).getTranslatedValue('copy_code'),
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
                color: AppColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
