import 'package:flutter/material.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  final List<Map<String, String>> _faqList = [
    {
      "question": "How do I place an order?",
      "answer": "Browse meals, select your desired items, add them to cart, and proceed to checkout. You can track your order status in real-time."
    },
    {
      "question": "What payment methods are accepted?",
      "answer": "We accept all major credit/debit cards, UPI, and digital wallets for secure and convenient payments."
    },
    {
      "question": "How do I modify my dietary preferences?",
      "answer": "Go to Profile > Diet Preferences to update your dietary restrictions and food preferences."
    },
    {
      "question": "What is the delivery radius?",
      "answer": "We currently deliver within a 10km radius of our partner restaurants to ensure food quality."
    },
    {
      "question": "Can I schedule orders in advance?",
      "answer": "Yes, you can schedule orders up to 7 days in advance through our pre-order feature."
    },
  ];

  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _isExpandedList = List.filled(_faqList.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: const Text(
          'Support Center',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "How can we help you?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Find answers to common questions below",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _faqList.length,
              itemBuilder: (context, index) => _buildFAQItem(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Still need help?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Launch email client
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Contact Support",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            _faqList[index]["question"]!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: Icon(
            _isExpandedList[index] ? Icons.remove : Icons.add,
            color: const Color(0xFF8BC34A),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpandedList[index] = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                _faqList[index]["answer"]!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}