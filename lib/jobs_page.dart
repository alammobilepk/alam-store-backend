import 'package:flutter/material.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs & Gigs Marketplace", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF004AAD), borderRadius: BorderRadius.circular(15)),
              child: const Column(
                children: [
                  Icon(Icons.badge, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text("Find Work or Hire Experts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Presented by Alam Enterprises", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            _jobActionCard(context, "I am Looking for a Job", "Upload your CV and let companies find you.", Icons.upload_file, Colors.green),
            const SizedBox(height: 15),
            _jobActionCard(context, "I want to Hire Someone", "Post your job details and find the best person.", Icons.person_search, Colors.blue),
            
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("Recent Job Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            
            // Sample Job List
            _jobTile("Mobile Developer Needed", "Alam Enterprises", "Remote"),
            _jobTile("Graphic Designer", "Tech Solution", "Gujranwala"),
          ],
        ),
      ),
    );
  }

  Widget _jobActionCard(BuildContext context, String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.3))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {},
      ),
    );
  }

  Widget _jobTile(String title, String company, String loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$company • $loc"),
        trailing: const Text("Apply", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
      ),
    );
  }
}