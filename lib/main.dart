import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myproj/Home.dart';
import 'dart:convert';

import 'package:myproj/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      
      home:LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. المخازن (Controllers) لكل الخانات عشان نقدر ناخد النص منها
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final questionController = TextEditingController();
  final essayController = TextEditingController();
  final modelAnswerController = TextEditingController();

  String result = "";
  bool loading = false;

  // 2. الفانكشن اللي بتبعت البيانات للسيرفر
  Future<void> sendEssay() async {
    setState(() { loading = true; });

    // لو شغال على emulator الأندرويد سيب الـ IP ده زي ما هو 10.0.2.2
    final url = Uri.parse("http://10.0.2.2:5217/api/Grading/grade");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "studentName": nameController.text,
          "subject": subjectController.text,
          "question": questionController.text,
          "studentAnswer": essayController.text,
          "modelAnswer": modelAnswerController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("--- Server Data: $data ---");
        String score = data["grade"].toString(); 
        String feedback = data["Feedback"] ?? "AI evaluated the answer.";
        String answer = essayController.text;
        
        // بنعرض السكور والـ Feedback تحت بعض
        result = "Score: $score% \n\n Feedback: $feedback"; // السطر ده هيطبع لنا السيرفر باعت إيه بالظبط
        setState(() {
        // غيرنا الـ s لـ S والـ f لـ F عشان الـ C# بيبعتهم كدة
        //String score = data["grade"].toString(); 
       // String feedback = data["Feedback"] ?? "AI evaluated the answer.";
        
        
        // بنعرض السكور والـ Feedback تحت بعض
        result = "Score: $score% \n\n Feedback: $feedback";
        loading = false; 
      });
      await Future.delayed(const Duration(seconds: 8));
      if (mounted) { // للتأكد إن المستخدم مخرجش من الصفحة أثناء الـ 5 ثواني
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                
                score: score,
                feedback: feedback,
                studentAnswer: answer,
                modelAnswer: modelAnswerController.text
              ),
            ),
          );
        }
      }else {
      setState(() { 
        result = "Server Error (Status: ${response.statusCode})"; 
        loading = false;
      });
    }
  } catch (e) {
    setState(() { 
      result = "Check Server Connection"; 
      loading = false;
    });
  }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية مريحة للعين
      appBar: AppBar(
        centerTitle: true,
        title: const Text("AutoGrade"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView( // حل مشكلة الـ Overflow لما الكيبورد يفتح
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(20.0),
            child:Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("AutoGrade", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    const SizedBox(height: 20),
                    
                    // استخدام الـ Widgets المخصصة للـ Form
                    customField("Student Name", nameController),
                    const SizedBox(height: 15),
                    customField("Subject", subjectController),
                    const SizedBox(height: 15),
                    customField("Question", questionController),
                    const SizedBox(height: 15),
                    customField("Student Response", essayController, maxLines: 4),
                    const SizedBox(height: 15),
                    customField("Model Answer", modelAnswerController, maxLines: 4),
                    
                    const SizedBox(height: 20),

                    // عرض السكور لو موجود
                    if (result.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration( borderRadius: BorderRadius.circular(10)),
                        child: Text(result, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),

                    const SizedBox(height: 20),

                    // الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loading 
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: sendEssay,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                minimumSize: const Size(120, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Submit", style: TextStyle(color: Colors.white)),
                            ),
                        const SizedBox(width: 15),
                        OutlinedButton(
                          onPressed: () {
                            // تنظيف كل الخانات
                            nameController.clear();
                            subjectController.clear();
                            questionController.clear();
                            essayController.clear();
                            modelAnswerController.clear();
                            setState(() { result = ""; });
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 48),
                            side: BorderSide(color: Colors.blue[900]!),
                          ),
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }

  // ويدجت خاصة لرسم حقول الإدخال بشكل متناسق
  Widget customField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}