import 'package:choigari/networking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'Index.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:math';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
 
  String newUserEmail = "";  // 入力されたメールアドレス
  String newUserPassword = ""; // 入力されたパスワード
  String infoText = ""; // 登録結果に関する情報
  String newUserName =""; //入力されたユーザ名
  String url = ""; //写真のURL
  String? mac; //Wi-Fiによって取得されるアドレス
  Reference pathReference = FirebaseStorage.instance.refFromURL("gs://eagles-choigari-dev.appspot.com/no_image.png");
  String? locate_image;

  void initState() {
    fetch_address();
    _get_url();
    super.initState();
  }
  
  void fetch_address() async {
    var addr = await ChoigariNetwork.getWifiBSSID();
    setState(() {
      mac = addr;
    });
  }


  void _get_url() async{
      int num = Random().nextInt(6);
      Reference pathReference = FirebaseStorage.instance.refFromURL("gs://eagles-choigari-dev.appspot.com/no_image"+num.toString()+".png");
      String imageurl = await pathReference.getDownloadURL();
      setState(() {
        url = imageurl;
      });
  }
  
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('ちょい借り',style: TextStyle(color:Colors.white),),),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            children: <Widget>[

              SizedBox(height: _size.height*0.1),
              //Text('Sign Up',style: TextStyle(fontSize: 30.0,color: Colors.white)),
              //SizedBox(height: _size.height*0.09),

              TextFormField(
                // 名前の入力
                decoration: const InputDecoration(
                  hintText: "名前",
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                   border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {
                    newUserName = value;
                  });
                },
              ),
              SizedBox(height: _size.height*0.04),

              TextFormField(
                // メールアドレスの入力
                decoration: const InputDecoration(
                  hintText: "メールアドレス",
                  prefixIcon: Icon(
                    Icons.markunread,
                  ),
                   border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {
                    newUserEmail = value;
                  });
                },
              ),

              SizedBox(height: _size.height*0.04),
              TextFormField(
                //パスワードの入力
                decoration: const InputDecoration(
                  hintText: "パスワード(６文字以上)",
                  prefixIcon: Icon(
                    Icons.lock,
                  ),
                   border: OutlineInputBorder(),
                ),
                // パスワードが見えないようにする
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    newUserPassword = value;
                  });
                },
              ),

              SizedBox(height: _size.height*0.08),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // メール/パスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential result =
                    await auth.createUserWithEmailAndPassword(
                      email: newUserEmail,
                      password: newUserPassword,
                    );
                   

                    // 登録したユーザー情報
                    final User user = result.user!;
                    await user.updateDisplayName(newUserName);
                    await user.updatePhotoURL(url);
                    
                    final db = FirebaseFirestore.instance;
                    final user_info = <String, dynamic>{
                          "name": newUserName,
                          "user_uid": user.uid,
                          "evaluation": 0.0,
                          "ImgURL": url,
                          "borrow_num":0,
                          "lend_num":0,
                          "receive_good_num":0
                                              };
                    
                    db.collection('Users').add(user_info);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    print(user.uid);
                    return IndexPage(mac: mac!);
                    }));

                  } catch (e) {
                    // 登録に失敗した場合
                    setState(() {
                      infoText = "登録NG：${e.toString()}";
                    });
                  }
                },
                child: Text("登録",style: TextStyle(color: Colors.white,fontSize: 20),),
              ),

              
              
          
              const SizedBox(height: 8),
              Text(infoText),
            ],
          ),
        ),
      ),
    );
  }
}