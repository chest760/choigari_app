import 'package:choigari/Index.dart';
import 'package:choigari/networking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'Sign_up.dart';


Future<void> main() async {
  // Firebase初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ちょい借り',
      theme: ThemeData(  
        primarySwatch: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false, //デバッグタグを除去
      home: HomePage()
    );
  }
}
      
class HomePage extends StatefulWidget {   
  
  _HomePageState  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  
  late AnimationController _controller; //アニメーションを操作する
  late Animation<double> _rotateAnimation; //角度を生成する

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 20), //アニメーションの時間
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {});
    });

    //回転する角度の設定
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(_controller);
    _controller.forward();

  }

  @override
  void dispose() {
     super.dispose();
    _controller.dispose();
  }

    
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return Container( //ここ変えた46-53
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 213, 243, 253), Color.fromARGB(255, 163, 246, 249)],
          // colors: [Color.fromARGB(255, 238, 245, 44), Color.fromARGB(255, 243, 140, 198)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child:  Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('ちょい借り',style: TextStyle(color:Colors.white),), 
          backgroundColor: Colors.lightBlue,
          automaticallyImplyLeading: false,
        ),
        // backgroundColor: Colors.pink,
        body: SafeArea(
          child:Center(          
            child: Column(  
              //mainAxisSize: MainAxisSize.min,
              children: <Widget>[  

                SizedBox(height: _size.height*0.1),
                Container(
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child:Image.asset('images/g1128.png'),
                  ),
                  height: 300,
                  width: 1000,
                ),

                SizedBox(height:_size.height*0.06),
                SizedBox(
                  height: 45,
                  width: 150,
                  child: ElevatedButton(
                    child: const Text('Log in',style: TextStyle(fontSize: 30.0),),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.lightBlue,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        ChoigariNetwork.getWifiBSSID().then((value) => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return IndexPage(mac: value);
                              },
                            ),
                          )
                        });
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginPage();
                            }
                          )
                        );
                      }
                    },
                  ),
                ),
            
                SizedBox(height: _size.height*0.08),
                SizedBox(    
                  height: 45,
                  width: 150,       
                  child: ElevatedButton(
                    child: const Text('Sign up',style: TextStyle(fontSize: 30.0),),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SignupPage();
                        }
                      )
                    );
                  },),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
