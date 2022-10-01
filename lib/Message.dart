import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Message_index.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bubble/bubble.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:intl/intl.dart';


class End_Dialog extends StatefulWidget{
  final String? mac;
  final String? user_uid;
  final DocumentReference<Map<String, dynamic>>? db;
  const End_Dialog({Key? key,this.mac,this.user_uid,this.db}) : super(key: key);
  _End_DialogState createState() => _End_DialogState();
}

class _End_DialogState extends State<End_Dialog> {

  bool good_status=false;
  bool bad_status = false;
  final user_db = FirebaseFirestore.instance.collection('Users');
  int? good_num;

  Future<void> get_good_num()async{
      await user_db.where('user_uid',isEqualTo: widget.user_uid).get().then((value) {                    
        setState(() {
          if (good_status==true){
            good_num = value.docs[0].data()['receive_good_num'] + 1;
          }
          else{
            good_num = value.docs[0].data()['receive_good_num'];
          }  
        });   
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('やり取りを終了しますか？\n貸した相手の評価をしてください',style: TextStyle(fontSize: 15),), 
      
      actions: [   
        Column(
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[    
                Column(
                  children: <Widget>[    
                    IconButton(
                      onPressed: (){
                        setState(() {
                          good_status = !good_status;
                          bad_status = false;
                        });
                      },
                      icon: Icon(
                        Icons.thumb_up_alt,
                        color: good_status ? Colors.red :Colors.grey
                      ),   
                    ),
                    Text('Good',style: TextStyle(color: good_status? Colors.red :Colors.grey),)
                  ],
                ),
                SizedBox(width: 35,),

                Column(
                  children: <Widget>[    
                    IconButton(
                      onPressed: (){
                        setState(() {
                          bad_status = !bad_status;
                          good_status = false;
                        });
                      }, 
                      icon: Icon(
                        Icons.thumb_down_alt,
                        color: bad_status ? Colors.blue :Colors.grey
                      ),   
                    ),
                    Text('Bad',style: TextStyle(color: bad_status? Colors.blue :Colors.grey),)
                  ],       
                ),
              ]
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Text('戻る'),
                ),
                SizedBox(width: 25,),

                TextButton(
                  onPressed: (){
                    if (good_status==true || bad_status==true){
                      widget.db!.
                      collection('message').
                      get().
                      asStream().
                      forEach((elements) {
                        for (var element in elements.docs){
                          element.reference.delete();
                        }
                      });
                      widget.db!.delete();

                      get_good_num();

                      user_db.where('user_uid',isEqualTo: widget.user_uid).get().then((value) {
                        if(good_status==true)  {
                            user_db.doc(value.docs[0].id).update({'receive_good_num': good_num!});
                        }
                        user_db.doc(value.docs[0].id).update({'evaluation': good_num!/value.docs[0].data()['borrow_num']});
                        


                      });

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return MessageIndexPage(mac: widget.mac!);
                          }
                        )
                     );} 
                  },
                  child: Text('送信'),
                ),
              ],
            )
          ]
        ),
     ],
                    );

  }

}



class MessagePage extends StatefulWidget {
  final DocumentSnapshot<Object?> document;
  final String Imgurl;
  final String name;
  final String user_uid;
  final DocumentReference<Map<String, dynamic>> db;
  final String mac;
  final int? flag;
  //final Stream<QuerySnapshot<Map<String, dynamic>>>  posts;
  const MessagePage({Key? key, required this.document, required this.Imgurl, required this.name, required this.user_uid, required this.db, required this.mac, this.flag}) : super(key: key);

  @override
   _MessagePageState createState() => _MessagePageState();  
  
}

class _MessagePageState extends State<MessagePage> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? messages;
  String? send_message;
  String? userImgurl;
  TextEditingController _textEditingController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  var now = DateTime.now();
  String accept_user = "";
  String accept_user_imgurl = "";
  bool?  status;
  bool bad_status = false;
  bool good_status = false;
  
  @override
  void initState() {
    if(widget.flag == 1){
      get_name(widget.document.get('accept_user'));
    }

    if (user != null) setState(() {
      userImgurl = user!.photoURL;
    });
    setState(() {
      messages = widget.db.collection('message').orderBy("CreatAt", descending: true).limit(20).snapshots();
    });
    widget.db.get().then((value){
      setState(() {
           status= value.get('status');
      });
      });
    super.initState();
  }

  

  Future<void> get_name(user_uid)async{
          await FirebaseFirestore.instance
            .collection("Users")
            .where('user_uid', isEqualTo: user_uid)
            .get()
            .then((name) {
              setState(() {
                if(name.docs.length != 0) {
                  accept_user = name.docs[0].data()['name'];
                  accept_user_imgurl = name.docs[0].data()['ImgURL'];
                }
              });
            });
          
     
  }

  

  

    Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: widget.flag != 1
               ?Text(widget.name,style: TextStyle(color:Colors.white),)
               :Text(accept_user,style: TextStyle(color:Colors.white),),


        automaticallyImplyLeading: false,
        leading:  IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          //child:Text('',style: TextStyle(fontSize: 15.0,color: Colors.black)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return MessageIndexPage(mac: widget.mac);
                }
              )
            );
          },
        ),
      actions: [
        TextButton(
          onPressed: (){
               showDialog(
                  context: context,
                  builder: (BuildContext context){  
                    return End_Dialog(mac: widget.mac,user_uid: widget.user_uid, db:widget.db);
                  }
                );
          },
          child: status==true && user!.uid == widget.document.get('accept_user')? Text('完了     ',style: TextStyle(color: Colors.white),):Text(''),
        )
      ],


      ),

      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 32.0,
                ),
                    
                child: StreamBuilder<QuerySnapshot> (
                  stream: messages,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                      
                    return SingleChildScrollView( 
                      child: Column(
                        children: [
                          for (final document in snapshot.data!.docs.reversed)
                            if (document.get('sendUser') == user!.uid)
                              right_message(document)
                              
                            else
                              left_message(document),
                          
                        ],
                      ),
                    );  //return left_message(snapshot.data!.docs[count].get('text'));
                  }
                ),                    
              )
            ),
            newMethod()
          ],
        ),
      ),

      );
    }

    Align left_message(document) {
      return Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.1,
          child: Row(
            mainAxisAlignment:MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children:[
                    //widget.document.get('accept_user') == user!.uid || widget.flag == 0 
                    Image.network(widget.Imgurl, width: 50,height: 50,fit: BoxFit.cover),
                    //:Image.network(accept_user_imgurl, width: 50,height: 50,fit: BoxFit.cover),
                    
                    Text(DateFormat('hh:mm').format(document.get('CreatAt').toDate())),
                  ]
                ),
                const SizedBox(width: 12.0),
                Flexible(
                    child: Column(
                      children:[
                        Align(
                          alignment: Alignment.bottomLeft,
                          heightFactor: 1.8,
                          child: //widget.document.get('accept_user') == user!.uid || widget.flag == 0
                                 Text(widget.name,style: TextStyle(fontSize: 10.0,color: Colors.black))
                                 //: Text(accept_user,style: TextStyle(fontSize: 10.0,color: Colors.black))
                        ),

                        Bubble(
                          margin: BubbleEdges.only(top: 5,right: 80),         
                          alignment: Alignment.topLeft, 
                          color: Colors.lightGreenAccent[200],
                          child: Text(document.get('text'),style: TextStyle(fontSize: 15,)),
                        ),
                      ]
                ),
                ),
              ],
          ),
        ); 
    }

     Align right_message(document) {
      return 
      Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.1,
          child: Row(
            mainAxisAlignment:MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  children:[
                  Align(
                    alignment: Alignment.bottomRight,
                    heightFactor: 1.8,
                    child: Text(user!.displayName!,style: TextStyle(fontSize: 10.0,color: Colors.black)),
                  ),
 
                  Bubble(
                  margin: BubbleEdges.only(top:5,left: 80),         
                  alignment: Alignment.topRight,
                  color: Colors.lightGreenAccent[200],
                  child: Text(document.get('text'),style: TextStyle(fontSize: 15)),
                ),
                  
                  ]
                ),
              ),
              const SizedBox(width: 8.0),
              //CircleAvatar(),

              Column(
                children:[
                  Image.network(userImgurl!, width: 50,height: 50,fit: BoxFit.cover),
                  Text(DateFormat('hh:mm').format(document.get('CreatAt').toDate())),

                ]
              )
            ],
          ),
        );
      }




    Container newMethod() {
      return Container(
            height: 68,
            child: Row(
              children: [
                SizedBox(width: 5,),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(48),
                    ),

                    child: TextField(
                      controller: _textEditingController,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'メッセージ',
                      ),
                      onChanged: (message) => send_message = message,
                    
                   )
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: (){ 
                    if(send_message != null){
                      _textEditingController.clear();
                      final content = <String, dynamic>{
                          "sendUser": user!.uid,
                          "CreatAt" : DateTime.now(),
                          "uid": widget.document.id,
                          "text": send_message,
                       };
                      widget.db.collection('message').add(content);
                      send_message = null;
                    }
                  }
                ),
              ],
            ),
          );
    }
}