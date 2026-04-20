import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String score;
  final String feedback;
  final String studentAnswer;
  final String modelAnswer;

  // بنخلي الصفحة تستقبل البيانات دي وهي بتفتح
  const Home({
    super.key,
    required this.score,
    required this.feedback,
    required this.studentAnswer,
    required this.modelAnswer,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final formkey = GlobalKey<FormState>();
  
  // بنعمل Controllers عشان نعرض فيهم الكلام اللي جاي من الصفحة الأولى
  late TextEditingController answerController;
  late TextEditingController feedbackController;

  @override
  void initState() {
    super.initState();
    // بنملا الـ Controllers بالبيانات اللي استقبلناها
    answerController = TextEditingController(text: widget.studentAnswer);
    feedbackController = TextEditingController(text: widget.feedback);
  }

  @override
  Widget build(BuildContext context) {
    int finalScore = int.tryParse(widget.score) ?? 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Feedback', style: TextStyle(fontSize: 25, color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.black))
        ],
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView( // عشان لو الكلام كتير الشاشة متعملش Error
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'STUDENT ANSWER',
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: answerController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // الدائرة الصفراء اللي فيها الدرجة
                    
                    Container(
                      width: 70,
                      height: 70,
                      decoration:  BoxDecoration(color: finalScore >= 50 ? Colors.green : Colors.red, shape: BoxShape.circle),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.score}/100', // عرض الدرجة
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                          ),
                          const Text('Score', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                const Text('MODEL ANSWER', 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),
              TextFormField(
            initialValue: widget.modelAnswer,
            maxLines: 5, // ده هيجبر الخانة إنها تظهر كبيرة بـ 5 سطور دايماً
            readOnly: true, // عشان الطالب ميعرفش يمسح أو يعدل الإجابة النموذجية
            style: TextStyle(fontSize: 14, color: Colors.blue.shade900, height: 1.4),
            decoration: InputDecoration(
            filled: true,
             fillColor: const Color(0xFFE3F2FD), // اللون الأزرق الفاتح من الصورة
             isDense: true,
            // تنسيق الحدود عشان تطلع زي الصورة بالضبط
            enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
           focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.blue.shade100),
    ),
  ),
),

              const SizedBox(height: 40),
                const Text(
                  'Feedback Summary',
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    TextFormField(
                      controller: feedbackController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const Positioned(right: 10, top: 10, child: Icon(Icons.copy, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // يرجعك ترفع إجابة تانية
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Try Again', style: TextStyle(color: Colors.white,fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('View Report', style: TextStyle(color: Colors.white,fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}