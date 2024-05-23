import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/components.dart';

class PaymentPolicy extends StatefulWidget {
  const PaymentPolicy({Key key}) : super(key: key);

  @override
  State<PaymentPolicy> createState() => _PaymentPolicyState();
}

class _PaymentPolicyState extends State<PaymentPolicy> {
  List json = [
    {
      'title':'مقدمة',
      'body':"شروط البيع التالية تحكم جميع المعاملات التجارية التي تتم من خلال الموقع الإلكتروني canariapp.com أي معاملة تجارية تتم من خلال هذا الموقع الإلكتروني تفترض قبول غير مشروط وغير قابل للإلغاء لهذه الشروط من قبل الزبون."
    },
    {
      'title':'الغرض',
      'body':'تهدف هذه الشروط لتحديد حقوق والتزامات الأطراف المعنية بعمليات البيع عن طريق الإنترنت و عبر الموقع الإلكتروني canariapp.com'
    },
    {
      'title':'عملية البيع',
       'body':'عند الدخول للموقع الإلكترونيcanariapp.com ، يقوم الزبون باختيار العناصر التي يرغب في شرائها ، و يملأ معلومات تعريف الهوية الخاصة به ، ويقبل الشروط. يتم بعد ذلك توجيه الزبون عبر الإنترنت إلى منصة الدفع الآمنة لمركز النقديات حيث يقوم بإكمال معلومات الدفع الخاصة به.'
    },
    {
      'title':'طرق الدفع',
      'body':'للدفع بواسطة بطاقة الائتمان، يقوم الزبون بإدخال الإحداثيات والرقم السري لبطاقة الدفع الخاصة به. عندما يتم قبول المعاملة من قبل البنك و يؤكد الموقع الإلكتروني. canariapp قبول العملية، يتم خصم المبلغ من حساب الزبون في يوم العمل التالي لتاريخ تأكيد المعاملة.يتم تأمين الدفع عبر الإنترنت من قبل مركز النقديات الذي يوفر خدمة دفع آمنة بالكامل. يضمن الزبون للموقع الإلكتروني canariapp.com امتلاكه الأموال الكافية لاستخدام طريقة الدفع التي اختارها خلال عملية الدفع. عند الدفع عن طريق بطاقة الائتمان، الأحكام المتعلقة باستخدام طريقة الدفع هذه، والمنصوص عليها في الاتفاقيات المبرمة بين الزبون وبنكه، وبين الموقع الإلكتروني cnariapp.com وبنكه، تأخذ بعين الإعتبار.',
    },
    {
      'title':'خصوصية البيانات',
      'body':'تتم معالجة المعلومات المطلوبة من الزبون أثناء الشراء عبر الموقع الإلكتروني canariapp.com بسرية. لدى الزبون الحق في الإطلاع أو تصحيح هذه المعلومات الشخصية بإرسال طلب عن طريق البريد الإلكتروني التاليcontact@canariapp.com.'
    },
    {
      'title':'إثبات عملية الدفع',
       'body':'تتم معالجة المعلومات المطلوبة من الزبون أثناء الشراء عبر الموقع الإلكتروني canariapp.com بسرية. لدى الزبون الحق في الإطلاع أو تصحيح هذه المعلومات الشخصية بإرسال طلب عن طريق البريد الإلكتروني التاليcontact@canariapp.com .'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'سياسة البيع',
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
      body:  SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 12,top: 12),
                child: Text('شروط البيع عبر الإنترنت',style: TextStyle(
                    color:Color(0xFFfb133a),
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 12,top: 12),
                child: Text('ندعوك لقراءة هذه الشروط والأحكام المتعلقة بالبيع عبر الإنترنت من قبل الموقع الإلكتروني www.canariapp.com يعتبر إتمام عملية الدفع من قبلكم بمثابة قبول لا رجعة فيه لهذه الشروط.'),
              ),
              ListView.builder(
                  physics:NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: json.length,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20,bottom: 12,top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('${json[index]['title']}',style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),),
                          height(12),
                          Text('${json[index]['body']}'),

                          if(json[index]['links']!=null)

                            Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 5),
                              child: Text('- ${json[index]['links'][0]}',style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline
                              ),),
                            ),
                          height(0),
                          if(json[index]['links']!=null)
                            Padding(
                              padding: const EdgeInsets.only(top: 0,bottom: 5),
                              child: Text('- ${json[index]['links'][1]}',style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline
                              ),),
                            ),
                          height(0),
                          if(json[index]['services']!=null)
                            ...json[index]['services'].map((e){
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text('- ${e}'),
                              );
                            }),
                          if(json[index]['services']!=null)
                            height(5),
                          Text('نريد إبلاغ مستخدمي هذه الخدمة أن هذه الأطراف الثالثة لديها حق الوصول إلى معلوماتك الشخصية. والسبب هو أداء المهام الموكلة إليهم نيابة عنا. ومع ذلك ، فهم ملزمون بعدم الكشف عن المعلومات أو استخدامها لأي غرض آخر')
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
