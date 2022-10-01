import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Post_detail.dart';
import 'Footer.dart';
import 'main.dart';
import 'package:intl/intl.dart';



class IndexPostRow extends StatefulWidget {
  final FirebaseFirestore db;
  final DocumentSnapshot post;
  final String mac;
  const IndexPostRow(this.db, this.post, this.mac) : super(key: null);

  @override
  _IndexPostRowState createState() => _IndexPostRowState();
}

class _IndexPostRowState extends State<IndexPostRow> {
  String? name;
  String? url;
  String? user_uid;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    fetchUser(widget.post.get('uid'));
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
      //evaluation = value.docs[0].data()['evaluation'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (url != null){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Post_detailPage(
                    document: widget.post, Imgurl: url!, name: name!, user_uid: user_uid!, mac: widget.mac);
                },
              ),
            );
          }
        },
        onLongPress: () {
          print(widget.post.id);
          if (user_uid == user!.uid){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text('投稿を削除しますか？'),
                  actions: [
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        }, 
                        child: Text('キャンセル'),
                      ),

                      TextButton(
                        onPressed: () async{
                          await widget.db.collection("Posts").doc(widget.post.id).delete();
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return IndexPage(mac: widget.mac);
                         }));
                        }, 
                        child: Text('削除')
                      )
                  ],
                );
              },
            );

          }
        },

        child: ListTile(
            leading: url != null
                ? Image.network(url!,
                    height: 60.0, width: 60.0, fit: BoxFit.cover)
                : null,
            title: Text(widget.post.get('thing')),
            subtitle: name != null ? Text(name!+'  '+widget.post.get('time')) : null,
            trailing: user!.uid == user_uid ? Text('●',style: TextStyle(fontSize: 10.0,color: Colors.red)):null
            ),
      ),
    );
  }
}

class IndexPage extends StatefulWidget {
  
  final String mac;
  const IndexPage({Key? key,required this.mac}) : super(key: key);

  @override
   _IndexPageState createState() => _IndexPageState();  
}


class _IndexPageState extends State<IndexPage> {
  User? user;
  int count = 0;
  Stream<QuerySnapshot<Map<String, dynamic>>>? posts;
  //final pathReference = FirebaseStorage.instance.refFromURL("gs://test-project-20220830.appspot.com/no_image.png");
  final db = FirebaseFirestore.instance;
  
  @override
  void initState(){
    user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    posts =  db.collection("Posts").where('mac', isEqualTo: widget.mac).where('accept_user', isEqualTo: '').snapshots();
    if(mounted){ 
    setState(() {
      posts = posts;
      user = user;
    });}
    //print(user);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
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
          body: StreamBuilder<QuerySnapshot> (
          stream: posts,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children:  snapshot.data!.docs.map((DocumentSnapshot document){ 
              return IndexPostRow(db, document,widget.mac);
            }).toList().reversed.toList(),
          
          );
          
        
        }
          
          
        ),
        bottomNavigationBar: Footer(page_index: 0, mac: widget.mac,),
      );
  }
}