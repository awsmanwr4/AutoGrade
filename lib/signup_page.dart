import 'package:flutter/material.dart';
import 'package:myproj/Home.dart';
    
class SignupPage extends StatefulWidget {

  
  
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole; // ده اللي هيخزن "Student" أو "Doctor"

final TextEditingController _confirmPasswordController = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // نفس لون الخلفية اللي في الصورة
      body: Center(
        child: Container(
          width: 400, // عشان تطلع بشكل الكارت اللي في النص
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("AutoGrade", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              const SizedBox(height: 8),
              const Text("Create Your Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // الحقول (بشكل مختصر عشان تبدأ بيها)
              TextFormField(decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder())),
              const SizedBox(height: 12),
                // قائمة اختيار النوع (Role)
         DropdownButtonFormField<String>(
             value: _selectedRole,
              decoration: InputDecoration(
               labelText: "Choose Role",
               prefixIcon: const Icon(Icons.person_outline),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
             ),
              items: ["Student", "Doctor"].map((role) {
            return DropdownMenuItem(
                value: role,
              child: Text(role),
              );
               }).toList(),
               onChanged: (value) {
               setState(() {
               _selectedRole = value; // تحديث القيمة لما المستخدم يختار
             });
            },
           ),
           const SizedBox(height: 12),
              TextFormField(decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true,
              controller: _passwordController,),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                controller: _confirmPasswordController,                    // عشان الكلام يظهر نجوم ****
                decoration: InputDecoration(
                labelText: "Confirm Password", 
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // عشان يطلع واخد كيرف زي الصورة
              ),
              prefixIcon: const Icon(Icons.lock_outline), // لو حابب تضيف أيقونة القفل
              ),
             ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text.isNotEmpty && 
               _passwordController.text == _confirmPasswordController.text){
                // لو متطابقين، انقل لصفحة الهوم
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  Home(score: "0", // قيم افتراضية عشان ميعملش Error
      feedback: "Welcome! No feedback yet.",
      studentAnswer: "",
      modelAnswer: "",)),

             );


              }
              else if (_passwordController.text != _confirmPasswordController.text) {
             // لو مش متطابقين، طلع رسالة غلط
            ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
           content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
          ),
        );
       }
       else {
      // لو الحقول فاضية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
    }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50),backgroundColor: Colors.cyanAccent),
                child: const Text("Sign Up"),
              ),
              
              TextButton(
                onPressed: () => Navigator.pop(context), // يرجعك للوجين
                child: const Text("Already have an account? Login"),
              )
            ],
          ),
          )
        ),
      ),
    );
    
  }
}