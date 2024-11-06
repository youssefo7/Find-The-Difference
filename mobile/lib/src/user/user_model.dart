import 'package:flutter/cupertino.dart';

class StatisticsCardData {
  final String title;
  final int value;
  final IconData icon;
  final String description;
  StatisticsCardData(
      {required this.title,
      required this.value,
      required this.icon,
      required this.description});
}
