import 'package:flutter/widgets.dart';

abstract class Navigatable {
  Route get route;
  bool get withMene;

  String get name;
}

typedef Widget SlidePageBuilder(
    BuildContext context, double slideValue, bool isPopped);
