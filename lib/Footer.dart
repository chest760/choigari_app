import 'package:flutter/material.dart';
import 'Message_index.dart';
import 'Index.dart';
import 'MyPage.dart';
import 'Post.dart';


class Footer extends StatefulWidget {
  final int page_index;
  final String? mac;
  const Footer({ required this.page_index, this.mac}) :super(key:null);

@override
_Footerstate createState() => _Footerstate();
}

class _Footerstate extends State<Footer>{
  int? _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.page_index;
    super.initState();
  }
  
  void _onItemTapped(int index) {
    print(_selectedIndex);
     setState(() {
       _selectedIndex = index;
     });
     if (_selectedIndex != widget.page_index){
         if(_selectedIndex == 0){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                 return IndexPage(mac: widget.mac!);
               }));
         }
         else if(_selectedIndex == 1){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                 return MessageIndexPage(mac:widget.mac!);
               }));
         }

         else if(_selectedIndex == 2){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                 return PostPage();
               }));
         }

         else if(_selectedIndex == 3){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                 return MyPage();
               }));
         }
          
     } 
   }
  

@override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.format_list_bulleted), // アイコン
          label: '投稿一覧', // ボタン名
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.textsms), // アイコン
          label:'トーク', // ボタン名
        ),

         BottomNavigationBarItem(
          icon: Icon(Icons.add), // アイコン
          label:'投稿', // ボタン名
        ),

         BottomNavigationBarItem(
           icon: Icon(Icons.person), // アイコン
           label:'マイページ', // ボタン名
         ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex!, 
      onTap: _onItemTapped,
    );
  }
}