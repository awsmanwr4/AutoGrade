import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myproj/Home.dart';
import 'package:myproj/forget_page.dart';
import 'dart:convert';

import 'package:myproj/main.dart';
import 'package:myproj/signup_page.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // متغير لتحديد الدور المختار (معلم أو طالب)
  String selectedRole = 'Teacher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF), // لون خلفية مائل للزرقة كما في الصورة
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // زر Dark Mode العلوي
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF0D1B3E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nights_stay, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text("Dark Mode", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              
              // العنوان
              Text(
                "AutoGrade",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
              ),
              Text(
                "Sign in to your account",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              SizedBox(height: 30),
              Text("Choose your role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),

              // صف اختيار الأدوار (Teacher / Student)
              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      title: "Teacher",
                      subtitle: "Access all features and manage essays",
                      iconPath: 'assets/myimage2.png', // تأكد من إضافة الصور في pubspec.yaml
                      isSelected: selectedRole == 'Teacher',
                      onTap: () => setState(() => selectedRole = 'Teacher'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: RoleCard(
                      title: "Student",
                      subtitle: "Submit essay and view your results",
                      iconPath: 'assets/myimage1.png',


                      isSelected: selectedRole == 'Student',
                      onTap: () => setState(() => selectedRole = 'Student'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // حقل البريد الإلكتروني
              CustomTextField(
                controller: emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
              ),

              SizedBox(height: 16),

              // حقل كلمة المرور
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              // زر نسيت كلمة المرور
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) =>  ForgotPasswordPage()),
      );
                  },
                  child: Text("Forgot password?", style: TextStyle(color: Colors.blue[700])),
                ),
              ),

              SizedBox(height: 10),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E63EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                      // Navigator...
                      // 1. الشرط بتاعك الجميل
  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
    if (selectedRole == 'Teacher') {
      // لو مدرس يروح صفحة الـ HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (selectedRole == 'Student') {
      // لو طالب يروح صفحة الفيدباك (تأكد من اسم الكلاس عندك)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home(score: "60", // البيانات المطلوبة
      feedback: "No feedback yet",
      studentAnswer: "",
      modelAnswer: "",)), 
      );
    }else {
      // لو ضغط Login من غير ما يختار لا مدرس ولا طالب
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your role first!")),
      );
    }
    
    
   
    
  } 
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill in all fields!"),
        backgroundColor: Colors.red, // لون أحمر للتنبيه
      ),
    );
  }
                    }
                  },
                  child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 20),
              
              // خيار التسجيل الجديد
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                     Navigator.push(
                 context,
                  MaterialPageRoute(builder: (context) =>  SignupPage()),
                ); 
                    },
                    child: Text("Sign up", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ويدجت مخصصة لاختيار الدور ---
class RoleCard extends StatelessWidget {
  final String title, subtitle, iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  RoleCard({required this.title, required this.subtitle, required this.iconPath, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            // استبدل Icon بـ Image.asset إذا كان لديك صور جاهزة
           // Icon(title == "Teacher" ? Icons.school : Icons.person, size: 50, color: Colors.blue),
           Image.asset(
            iconPath, 
            height: 60, 
            fit: BoxFit.contain,
             errorBuilder: (context, error, stackTrace) {
           // لو المسار فيه غلطة، السهم الأحمر ده هيعرفك
             return Icon(Icons.warning, color: Colors.red, size: 50);
          },
         ),

            SizedBox(height: 8),

            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// --- ويدجت مخصصة للحقول ---
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  CustomTextField({required this.controller, required this.hintText, required this.icon, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword ? Icon(Icons.visibility_outlined, color: Colors.grey) : null,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }
}