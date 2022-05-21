import 'package:flutter/material.dart';
import 'package:whiteboard/whiteboard_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Whiteboard',
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: const WhiteboardPage(),
  ));
}
