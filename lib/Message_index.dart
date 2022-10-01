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
import 'main.dart';






class MessageRow extends StatefulWidget {
  final FirebaseFirestore db;
  final DocumentSnapshot document;
  final String mac;
  final int? flag;
  const MessageRow(this.db, this.document, this.mac, this.flag) : super(key: null);

  @override
  _MessageRowState createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  String? name=null;
  String? url=null;
  String? user_uid=null;

  @override
  void initState() {
    if(widget.flag==0) fetchUser(widget.document.get('uid'));
    if(widget.flag==1) fetchacceptUser(widget.document.get('accept_user'));
  }

  void fetchacceptUser(dynamic uid) async {
    final db = widget.db;
    if(uid!=''){
    final value = await db
        .collection("Users")
        .where("user_uid", isEqualTo: uid)
        .get();
    setState(() {
      url = value.docs[0].data()['ImgURL'];
      name = value.docs[0].data()['name'];
      user_uid = value.docs[0].data()['user_uid'];
    });
    }
  }


  void fetchUser(dynamic uid) async {
    final db = widget.db;
    final value = await db
        .collection("Users")
        .where("user_uid", isEqualTo: uid)
        .get();
    setState(() {
      url = value.docs[0].data()['ImgURL'];
      name = value.docs[0].data()['name'];
      user_uid = value.docs[0].data()['user_uid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          final db1 = FirebaseFirestore.instance.collection('Posts').doc(widget.document.id);
          if (url != null){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return 
                  MessagePage(
                    document: widget.document, Imgurl: url!, name: name!, user_uid: user_uid!, db: db1, mac: widget.mac,flag:widget.flag);
                },
              ),
            );
          }
        },
        child: ListTile(
          leading: url != null
            ? Image.network(url!,height: 60.0, width: 60.0, fit: BoxFit.cover)
            : null,
            title: Text(widget.document.get('thing')),
            subtitle: name != null ? Text(name!) : null,
            trailing: widget.document.get('accept_user') != ''
                      ? null
                      : Text('お助け待ち'),
        ),        
      ),
    );
  }
}




class MessageIndexPage extends StatefulWidget {
  
  final String mac;
  const MessageIndexPage({Key? key,required this.mac}) : super(key: key);

  @override
   _MessageIndexPageState createState() => _MessageIndexPageState();  
}


class _MessageIndexPageState extends State<MessageIndexPage> {
  User? user;
  int count = 0;
  int flag = 0;
  Stream<QuerySnapshot<Map<String, dynamic>>>? posts;
  Stream<QuerySnapshot<Map<String, dynamic>>>? accepts;
  final db = FirebaseFirestore.instance;
  
  @override
  void initState(){
    user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    posts =  db.collection("Posts").where('mac', isEqualTo: widget.mac).where('uid', isEqualTo: user!.uid).snapshots();
    accepts = db.collection("Posts").where('mac', isEqualTo: widget.mac).where('accept_user', isEqualTo: user!.uid).snapshots();
    if(mounted){ 
      setState(() {
        posts = posts;
        user = user;
        accepts = accepts;
      });
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ちょい借り',style: TextStyle(color:Colors.white),),
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
            icon: Icon(Icons.logout,color: Colors.white)
          )
        ],
      ),
      body: SafeArea(
        
        child: Column(
          children:  <Widget>[
            Row(
              children: [
                SizedBox(
                  width: _size.width*0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: (flag==1) ? Color.fromARGB(255,198,196,196):Colors.lightBlue //ボタンの背景色
                    ),
                  child: Text('貸しているもの',style: TextStyle(color:Colors.white),),
                  onPressed: (){
                    setState(() {
                    flag = 0;  
                    });
                  },
                  )
                ),
                SizedBox(
                  width: _size.width*0.5,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      primary: (flag==0) ?Colors.grey:Colors.lightBlue //ボタンの背景色
                    ),
                    child: Text('借りているもの',style: TextStyle(color:Colors.white),),
                    onPressed: (){
                    setState(() {
                    flag = 1;  
                    });
                    
                    },
                  ),
                ),
              ],
            ),
            if (flag==0) 
            AcceptsMethod()
            else PostsMethod()  
          ],
        
        ),
      ),
      bottomNavigationBar: Footer(page_index: 1, mac: widget.mac),
    );
  }






  PostsMethod() {
    return StreamBuilder<QuerySnapshot> (
      stream: posts,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
        }
        return Expanded(
          child : ListView(
            shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            children:  snapshot.data!.docs.map((DocumentSnapshot document){ 
              return MessageRow(db, document,widget.mac,flag);
            }).toList().reversed.toList(), 
          ),
        ); 
      }
    );    
  }
  
  AcceptsMethod() {
    return StreamBuilder<QuerySnapshot> (
      stream: accepts,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
        }
        return Expanded(
          child: ListView(
            shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            children:  snapshot.data!.docs.map((DocumentSnapshot document){ 
              return MessageRow(db, document,widget.mac,flag);
            }).toList().reversed.toList(),
          ),
        );
      }
    );  
  }

}