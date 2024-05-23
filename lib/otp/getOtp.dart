import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
bool isloading = true;
String phoneNumber;
String phoneCode = '+212';
String verificationid;
bool onEditing = true;
String code;
final GlobalKey<FormState> otpkey = GlobalKey<FormState>();
final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
Widget buildOtpForm({Function onCompleted,Function onEditing,Function onTap,otpkey,code}){
  return  Form(
    key: otpkey,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Mobile Verification',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.black),
          ),
          height(10),
          Text(
            'Enter the verifcation code received',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey),
          ),

          SizedBox(
            height: 15,
          ),
          VerificationCode(
              fullBorder: true,
              length: 6,
              onCompleted:onCompleted,
              onEditing:onEditing
          ),
          height(20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: GestureDetector(
              onTap:onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: code == null
                      ? Color(0xFF7B919D)
                      : AppColor,
                ),
                child: Center(
                    child: code == null
                        ? Text(
                      'next',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                        : CircularProgressIndicator(
                      color: Colors.white,
                    )),
                height: 58,
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          )
        ]),
  );
}