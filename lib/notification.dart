import 'package:flutter/widgets.dart';

class AppNotification extends Notification {
  final String message;
  final dynamic value;

  AppNotification(this.message, {this.value});
}