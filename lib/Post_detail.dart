import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Post_detail.dart';
import 'Message.dart';
import 'MyPage.dart';


class Post_detailPage extends StatefulWidget {
  final DocumentSnapshot<Object?> document;
  final String Imgurl;
  final String name;
  final String user_uid;
  final String mac;
  //final Stream<QuerySnapshot<Map<String, dynamic>>>  posts;
  const Post_detailPage({Key? key, required this.document, required this.Imgurl, required this.name, required this.user_uid, required this.mac}) : super(key: key);
 

  @override
   _Post_detailPageState createState() => _Post_detailPageState();  
  
}

class _Post_detailPageState extends State<Post_detailPage> {
    var now = DateTime.now();
    User? user = FirebaseAuth.instance.currentUser;
    String? name;
    String text = "";

    @override
  void initState() {
    if (user != null){
      name = user!.displayName;
    }
    text = 
          """$nameさん、承認ありがとうございます！
【借りたいもの】${widget.document.get('thing')}
【時間】${widget.document.get('time')}
【コメント】${widget.document.get('comment')}""";
    super.initState();
  }
    
    Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('ちょい借り',style: TextStyle(color:Colors.white),),),
      body: SingleChildScrollView( 
      child : Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: (){
               Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                 return MyPage(user_uid:widget.user_uid,imgurl:widget.Imgurl,name:widget.name,from_post: true,);
               }));
            },
            child: Center(
              child:Image.network(widget.Imgurl,height: 150, width: 150, fit:  BoxFit.cover)
            ),
          ),

          const SizedBox(height: 15),
          Center(
            child:Text(widget.name,style: TextStyle(fontSize: 25.0,color: Colors.black))
          ),

          const SizedBox(height: 50),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text("・借りたいもの",style:TextStyle(fontSize: 20.0,color: Colors.black, fontWeight: FontWeight.bold))
          ),
          const SizedBox(height: 10,),
            Text(widget.document.get('thing'),style: TextStyle(fontSize: 20),),

            const SizedBox(height: 20),
            Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text("・借りたい時間",style:TextStyle(fontSize: 20.0,color: Colors.black, fontWeight: FontWeight.bold))
          ),
            const SizedBox(height: 10,),
            Text(widget.document.get('time'),style: TextStyle(fontSize: 20),),

            const SizedBox(height: 35),
            Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text("・コメント",style:TextStyle(fontSize: 20.0,color: Colors.black, fontWeight: FontWeight.bold))
          ),
          const SizedBox(height: 10,),
            Text(widget.document.get('comment'),style: TextStyle(fontSize: 20),),
            
            
            const SizedBox(height: 30),
            
            if (widget.document.get('uid') != user!.uid)
            ElevatedButton(
              child: const Text('助ける',style: TextStyle(fontSize: 30.0, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.black,
                shape: const StadiumBorder()
              ),
              onPressed: () async{
                    final db = FirebaseFirestore.instance.collection('Posts').doc(widget.document.id);
                    final user_db = FirebaseFirestore.instance.collection('Users');
                    final content = <String, dynamic>{
                          "sendUser": widget.document.get('uid'),
                          "CreatAt" : now,
                          "uid": widget.document.id,
                          "text": text,
                    };
                await db.update({'accept_user': user!.uid,'status':true});
                user_db.where('user_uid',isEqualTo: user!.uid).get().then((value) {
                  user_db.doc(value.docs[0].id).update({'lend_num': value.docs[0].data()['lend_num']+1});
                });
                user_db.where('user_uid',isEqualTo: widget.user_uid).get().then((value) {
                  user_db.doc(value.docs[0].id).update({'borrow_num': value.docs[0].data()['borrow_num']+1});
                });
                db.collection('message').add(content);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MessagePage(document: widget.document, Imgurl: widget.Imgurl, name: widget.name, user_uid: widget.user_uid, db: db, mac:widget.mac,flag:0);
                
               }));
              },
            ),
          

        ]



      ),
      ),

     );
    }

}