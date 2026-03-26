// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';

// class Pixel extends StatelessWidget {
//   final Color color;
//   final String text;
//   const Pixel({super.key, required this.color, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final Color color;
  final String text;
  const Pixel({required this.color, this.text = '', super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // child: Center(child: Text(text, style: TextStyle(color: Colors.white))),
    );
  }
}
