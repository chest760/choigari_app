import 'dart:ui';

import 'package:choigari/networking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Message_index.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bubble/bubble.dart';
import 'Footer.dart';
//import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:network_info_plus/network_info_plus.dart';
import 'main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyPage extends StatefulWidget {
  final String? user_uid;
  final String? imgurl;
  final String? name;
  final bool? from_post;
  const MyPage({Key? key,this.user_uid,this.imgurl,this.name,this.from_post}) :super(key:null);

@override
_MyPagestate createState() => _MyPagestate();

}


class _MyPagestate extends State<MyPage>{
  User? user = FirebaseAuth.instance.currentUser;
  String? mac;
  String new_name = "";
  double evaluation = 0;
  int lend_num = 0;
  int borrow_num = 0;
  int flag = 0;
  //io.File? _image;
  io.File? file;
  
  final db = FirebaseFirestore.instance.collection('Users');



  @override
  void initState() {
    fetch_address();
    fetch_evaluation();
    super.initState();
  }

  @override
  void fetch_address() async {
    var addr = await ChoigariNetwork.getWifiBSSID();
    setState(() {
      mac = addr;
    });
  }

  void fetch_evaluation() async {
    if (widget.user_uid==null){
      await  db.where('user_uid',isEqualTo: user!.uid).get().then((value) {
          setState(() {
           evaluation = value.docs[0].data()['evaluation'];
           lend_num =  value.docs[0].data()['lend_num'];
           borrow_num = value.docs[0].data()['borrow_num'];
          }); 
        });
    }
    else {
      await  db.where('user_uid',isEqualTo: widget.user_uid).get().then((value) {
          setState(() {
           evaluation = value.docs[0].data()['evaluation'];
           lend_num =  value.docs[0].data()['lend_num'];
           borrow_num = value.docs[0].data()['borrow_num'];
          }); 
        });
    }
  }



  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          title: const Text('ちょい借り',style: TextStyle(color:Colors.white),),
          automaticallyImplyLeading: widget.from_post != null ?true :false,
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

        body: Column(
          children: [
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[

                widget.imgurl != null
                ?Image.network(widget.imgurl!,height: 150, width: 150, fit:  BoxFit.cover)
                :Image.network(user!.photoURL!,height: 150, width: 150, fit:  BoxFit.cover),
                // IconButton(
                //   icon: Icon(Icons.edit,color:Colors.grey),
                //   onPressed: (){
                //     //getImage();
                //     print(mac);
                //   }
                // ),
              ]
            ),
            const SizedBox(height: 20),
            
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                SizedBox(width: 20,),

                widget.name != null
              ?Text(widget.name!,style: TextStyle(fontSize: 30.0,color: Colors.black))
              :Text(user!.displayName!,style: TextStyle(fontSize: 30.0,color: Colors.black)),
                
                if(widget.user_uid == user!.uid || widget.user_uid==null)
                IconButton(
                  icon: Icon(Icons.edit,color:Colors.grey),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('名前編集'),
                          content:TextField(
                            onChanged: (value) {
                              setState(() {
                                new_name = value;
                              });
                            }
                          ),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              }, 
                              child: Text('キャンセル'),
                            ),

                            TextButton(
                              onPressed: () async {
                                if (!new_name.isEmpty)
                                await  db.where('user_uid', isEqualTo: user!.uid).get().then((value) {
                                  for(var doc in value.docs){
                                      db.doc(doc.id).update({'name':new_name});
                                  }
                                });
                                 await user!.updateDisplayName(new_name);
                                 Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                return MyPage();
                                }));
                              }, 
                              child: Text('完了')
                            )


                          ],
                        );
                      }
                    );
                    
                  }
                )
              ]
            ),

            SizedBox(height: 25,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  initialRating: 5*evaluation,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  glow: false,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Color.fromARGB(255, 223, 155, 9),
                  ),
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {  
                  },
                ),
                SizedBox(width: 20,),
                Text((5*evaluation).toStringAsFixed(2),style: TextStyle(fontSize:30,)),
              ],
            ),
            
            SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("貸した回数",style: TextStyle(fontSize: 20),),
                    Text(lend_num.toString(),style: TextStyle(fontSize: 20))
                  ],
                ),

                SizedBox(width: 50,),

                Column(
                  children: [
                    Text("借りた回数",style: TextStyle(fontSize: 20)),
                    Text(borrow_num.toString(),style: TextStyle(fontSize: 20))
                  ],
                ),
              ],
            )






            
          ]
       ),
      bottomNavigationBar: Footer(page_index: 3, mac: mac),
    );
  }
}