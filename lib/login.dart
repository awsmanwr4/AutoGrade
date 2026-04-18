import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myproj/main.dart';
class LoginPage extends StatelessWidget {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Login",style: TextStyle(fontSize: 36,fontWeight: FontWeight.bold),),
      centerTitle: true,),
      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 36),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.black)),
              onPressed: () {

                if(emailController.text.isNotEmpty &&
                   passwordController.text.isNotEmpty){

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );

                }

              },
              child: Text("Login",style: TextStyle(fontSize: 25,color: Colors.black),),
            )

          ],
        ),
      ),
    );
  }
}