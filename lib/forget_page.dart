import 'package:flutter/material.dart';
    
class ForgotPasswordPage extends StatelessWidget {
  
   ForgotPasswordPage({super.key}); 

  // الأداة دي بتتحط "بره" الـ Build
  final TextEditingController _emailController = TextEditingController();

  // الوظيفة دي برضه "بره" الـ Build
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زرار الرجوع الصغير اللي فوق
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text("Back to Login"),
                ),
              ),
              const SizedBox(height: 10),
              Text("AutoGrade", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              const SizedBox(height: 10),
              const Text("Forgot Password?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "No worries! Enter your email and we'll send you a link",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              // أيقونة الظرف اللي في الصورة
              const Icon(Icons.mail_outline, size: 60, color: Colors.black87),
              
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Enter your email address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              // زرار Send Reset Link
              ElevatedButton(
                onPressed: () {
                  String email = _emailController.text.trim();

  // 2. التحقق لو الحقل فارغ
  if (email.isEmpty) {
    _showSnackBar(context, "Please enter your email", Colors.orange);
    return; // وقف التنفيذ هنا
  }

  // 3. التحقق من صيغة الإيميل
  if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(email)) {
    _showSnackBar(context, "Invalid email format", Colors.red);
    return; // وقف التنفيذ هنا
  }

  // 4. في حالة النجاح (محاكاة)
  _showSnackBar(context, "Reset link sent successfully!", Colors.green);
  
  // انتظر ثانيتين ثم ارجع لصفحة اللوجين
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context);
  });

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // نفس درجة الأزرق في الصورة
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Send Reset Link", style: TextStyle(color: Colors.white)),
              ),
              
              const SizedBox(height: 15),
              const Text("or", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              
              // زرار Back to Login اللي تحت
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text("Back to Login", style: TextStyle(color: Colors.black87)),
              ),
              
              const SizedBox(height: 20),
              // الجزء اللي تحت خالص (Didnt receive the email)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Didn't receive the email?\nCheck your spam folder or try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
    
  
