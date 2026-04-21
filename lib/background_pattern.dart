import 'package:flutter/material.dart';

class PatternedBackground extends StatelessWidget {
  final Widget child;
  const PatternedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Blue Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004AAD), Color(0xFF002B6B)],
            ),
          ),
        ),
        
        // 2. Orange Circle Pattern (Top Left)
        Positioned(
          top: -60,
          left: -60,
          child: CircleAvatar(
            radius: 120,
            backgroundColor: Colors.orange.withOpacity(0.2),
          ),
        ),

        // 3. Green Box Pattern (Bottom Right)
        Positioned(
          bottom: -40,
          right: -40,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),

        // 4. White Glow Effect (Middle)
        Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        // 5. Asli Content (Login Form etc.)
        child,
      ],
    );
  }
}