import 'package:flutter/material.dart';

class ApplicationColorProvider extends ChangeNotifier {
  ApplicationColorProvider({required Color color}) : _color = color;

  Color _color;
  Color get color => _color;
  set color(Color color) {
    _color = color;
    notifyListeners();
  }
}
