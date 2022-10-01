import 'package:choigari/networking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Index.dart';
import 'package:network_info_plus/network_info_plus.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final info = NetworkInfo();
  

  // 入力されたメールアドレス（ログイン）
  String loginUserEmail = "";
  // 入力されたパスワード（ログイン）
  String loginUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";

  String username="";
  String? mac;
  String? url;
  
  @override
  void initState() {
    fetch_address();
    super.initState();
  }

  void fetch_address() async {
    var addr = await ChoigariNetwork.getWifiBSSID();
    setState(() {
      mac = addr;
    });
  }

  @override
  Widget build(BuildContext context){
    var _size = MediaQuery.of(context).size;
  
    return Scaffold(
      appBar: AppBar(title: const Text('ちょい借り',style: TextStyle(color:Colors.white)),),
      //backgroundColor: Colors.pink[200],
      body: Center(
        child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              
              SizedBox(height: _size.height*0.15),

              //Text('Log in',style: TextStyle(fontSize: 30.0,color: Colors.grey,)),
              //SizedBox(height: _size.height*0.1),
              
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "メールアドレス",
                  prefixIcon: Icon(
                    Icons.markunread,
                  ),
                   border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {
                    loginUserEmail = value;
                  });
                },
              ),
              
              SizedBox(height: _size.height*0.05),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "パスワード",
                  prefixIcon: Icon(
                    Icons.lock,
                  ),
                   border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    loginUserPassword = value;
                  });
                },
              ),
              SizedBox(height: _size.height*0.08),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // メール/パスワードでログイン
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential result =
                        await auth.signInWithEmailAndPassword(
                      email: loginUserEmail,
                      password: loginUserPassword,
                    );
                    // ログインに成功した場合
                    final User user = result.user!;
                    //setState(() {
                    //  infoText = "ログインOK：${user.email}";
                    //});
                    //content = _get_info(user.uid);
                    final db = FirebaseFirestore.instance;
                    await db.collection('Users').where('user_uid',isEqualTo: user.uid).get().then((value){
                      setState(() {
                        url = value.docs[0].data()['ImgURL'];
                      });
                    });

                    await user.updatePhotoURL(url);
                
                    Navigator.of(context).push(
                      MaterialPageRoute(
                      builder: (context) {
                        return IndexPage(mac: mac!);
                      },
                     ),
                    );
                  } catch (e) {
                    // ログインに失敗した場合
                    setState(() {
                      infoText = "ログインNG：${e.toString()}";
                    });
                  }
                },
                child: Text("ログイン",style: TextStyle(color:Colors.white,fontSize: 20)),
              ),
              const SizedBox(height: 8),
              Text(infoText),
            ],
          ),
        ),
        ),
      ),
    );
  }
}