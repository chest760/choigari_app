import 'dart:async';
import 'package:choigari/networking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Post_detail.dart';
import 'Footer.dart';
import 'Message.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'Index.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'main.dart';

class PostPage extends StatefulWidget{
  const PostPage({Key? key}) : super(key: key);

  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>{
  String? comment;
  String? start_time = DateFormat('MM/dd HH:mm').format(DateTime.now());
  String? end_time = DateFormat('MM/dd HH:mm').format(DateTime.now());
  String? determined_start_time;
  String? determined_end_time;
  String? uid;
  String? thing;
  String acceput_user = '';
  String? mac;
  String? data;
   final info = NetworkInfo();
  final db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();


  
  @override
  void initState() {
    fetch_address();
    super.initState();
  }

  
  @override
  void fetch_address() async {
    var addr = await ChoigariNetwork.getWifiBSSID();
    setState(() {
      mac = addr;
    });
  }

  
  void startPicker(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    var selectedIndex = 0;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: _size.height*0.4),
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  backgroundColor: Colors.grey.withOpacity(0.8),
                  use24hFormat: true,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (time) => setState(() {
                    start_time = DateFormat('MM/dd HH:mm').format(time);
                  }),  
                  mode: CupertinoDatePickerMode.dateAndTime,
                ),
              ),
              SizedBox(height:30),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                ),
                onPressed: (){
                   _controller2.value = TextEditingValue(text: start_time!);
                   setState(() {
                   determined_start_time = start_time;  
                   });
                   Navigator.pop(context);
                }, 
                child: Text('保存',style:TextStyle(fontSize: 20.0,color: Colors.white)),
              ),
            ]
          ),
        );
      },
    );
  }

  void endPicker(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    var selectedIndex = 0;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: _size.height*0.4),
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  backgroundColor: Colors.grey.withOpacity(0.8),
                  use24hFormat: true,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (time) => setState(() {
                    end_time = DateFormat('MM/dd HH:mm').format(time);
                  }),
                  mode: CupertinoDatePickerMode.dateAndTime,
                ),
              ),
              SizedBox(height:30),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                ),
                onPressed: (){
                  _controller3.value = TextEditingValue(text: end_time!);
                  setState(() {
                    determined_end_time = end_time;  
                  });
                  Navigator.pop(context);
                }, 
                child: Text('保存',style:TextStyle(fontSize: 20.0,color: Colors.white)),
              ),
            ]
          ),
        );
      },
    );
  }

  

  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
      return Scaffold(
       appBar: AppBar(
          title: const Text('ちょい借り',style: TextStyle(color:Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: (){
                 showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('ログアウトしますか？'),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          }, 
                          child: Text('いいえ'),
                        ),
                        TextButton(
                          onPressed: () async{
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return HomePage();
                            }));
                          }, 
                          child: Text('はい')
                        )
                      ],
                    );
                  }
                );
              }, 
              icon: Icon(Icons.logout,color: Colors.white,)
            )
          ],
        ),

        body: SafeArea(
          child :Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: _size.width*0.8,
                  height: _size.height*0.2,
                  child: TextField(
                    controller: _controller1,
                    autofocus: true,
                    decoration: InputDecoration(
                      enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      hintText: '借りたいもの'
                    ),
                    onChanged: (input_thing) => setState(() {
                      thing = input_thing;
                    }),
                  ),
                ),
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: _size.width*0.3,
                      child: TextField ( 
                        controller: _controller2,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          hintText: ' 借りる時間'
                        ),
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          startPicker(context);
                        }
                      ),
                    ),
                  Text(' ～ ',style: TextStyle(fontSize: 20.0)),
                  SizedBox(
                    width: _size.width*0.3,
                    child: TextField (
                      controller: _controller3,
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 13,
                        ),
                        hintText: ' 返す時間',  
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        endPicker(context);
                      }
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: _size.width*0.8,
                height: _size.height*0.2,
                child: TextField(
                  controller: _controller4,
                  keyboardType: TextInputType.multiline,
                  maxLines:5,
                  autofocus: true,
                  decoration: InputDecoration(
                    enabledBorder:  OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    hintText: 'コメント'
                  ),
                  onChanged: (input_comment) => setState(() {
                    comment = input_comment;
                  }),
                ),
              ),

              SizedBox(height: 15,),

              TextButton(
                onPressed: (){
                  if(comment == null || determined_start_time == null || determined_end_time == null || thing == null){
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('正しく入力してください'),
                        );
                      },
                    );
                  }
                  else{
                    _controller1.clear();
                    _controller2.clear();
                    _controller3.clear();
                    _controller4.clear();
                    final content = <String, dynamic>{
                          "accept_user": '',
                          "status": false,
                          "comment" : comment,
                          "mac": mac,
                          "thing": thing,
                          "time": determined_start_time! + " ～ " +determined_end_time!, 
                          "uid":user!.uid,
                      };
                    db.collection('Posts').add(content);
                    comment = null;
                    thing = null;
                    determined_start_time = null;
                    determined_end_time = null;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return IndexPage(mac: mac!);
                        }
                      )
                    );                    
                  }
                }, 
                
                child: Text('投稿',style: TextStyle(fontSize: 20),)
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(page_index: 2, mac: mac),
    );
  }
}