import 'package:flutter/material.dart';
import 'package:tooth_tales/screens/login.dart';
class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
            color: Colors.cyan,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/Images/toothstart.png"),
                Text("Tooth Tales", style: TextStyle(color:Colors.white,fontSize: 30, fontWeight: FontWeight.w900,),),
                SizedBox(height: 110,),
                Text("Find your best Dentists", style: TextStyle(color:Colors.white,fontSize: 20,),),
                Text("without wasting time", style: TextStyle(color:Colors.white,fontSize: 20,),),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );}, child: Text("Get Started", style: TextStyle(color:Colors.cyan,fontSize: 18,))),
              ],
            )
        )
    );
  }
}