import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildDrawerItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required Function() onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(
      title,
      style: GoogleFonts.poppins( // Apply Poppins font
        color: Colors.white,
        fontSize: 16, // Optional: Adjust size
        fontWeight: FontWeight.w500, // Medium weight
      ),
    ),
    onTap: onTap,
  );
}