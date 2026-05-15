import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/forget_page.dart';
import 'package:myproj/signup_page.dart';
import 'package:myproj/student_dashboard.dart';
import 'package:myproj/teacher_dashboard.dart';

const String apiBase = "http://10.0.2.2:5217";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'teacher';
  bool loading = false;
  String error = '';

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => error = "Please fill in all fields");
      return;
    }

    setState(() { loading = true; error = ''; });

    try {
      final response = await http.post(
        Uri.parse("$apiBase/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "role": selectedRole,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (selectedRole == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherDashboardPage(teacherName: data['name'] ?? ''),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardPage(
                studentName: data['name'] ?? '',
                studentGrade: data['grade'] ?? '',
              ),
            ),
          );
        }
      } else {
        setState(() => error = data['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => error = 'Cannot connect to server. Make sure the backend is running.');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B3E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nights_stay, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text("Dark Mode", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "AutoGrade",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
              ),
              Text("Sign in to your account", style: TextStyle(fontSize: 16, color: Colors.grey[600])),

              const SizedBox(height: 30),
              const Text("Choose your role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      title: "Teacher",
                      subtitle: "Access all features and manage essays",
                      iconPath: 'assets/myimage2.png',
                      isSelected: selectedRole == 'teacher',
                      onTap: () => setState(() => selectedRole = 'teacher'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RoleCard(
                      title: "Student",
                      subtitle: "Submit essay and view your results",
                      iconPath: 'assets/myimage1.png',
                      isSelected: selectedRole == 'student',
                      onTap: () => setState(() => selectedRole = 'student'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                  ),
                  child: Text("Forgot password?", style: TextStyle(color: Colors.blue[700])),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E63EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: loading ? null : handleLogin,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupPage()),
                    ),
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

class RoleCard extends StatelessWidget {
  final String title, subtitle, iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Image.asset(
              iconPath,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.warning, color: Colors.red, size: 50),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, color: Colors.grey) : null,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }
}
