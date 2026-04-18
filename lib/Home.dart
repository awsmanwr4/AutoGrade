import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String score;
  final String feedback;
  final String studentAnswer;

  // بنخلي الصفحة تستقبل البيانات دي وهي بتفتح
  const Home({
    super.key,
    required this.score,
    required this.feedback,
    required this.studentAnswer,
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
                const SizedBox(height: 50),
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
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
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
                const SizedBox(height: 80),
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