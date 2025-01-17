import 'package:flutter/cupertino.dart';

class DetailDateTimePanel extends StatelessWidget {
  static const panelName = 'detail_datetime';

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onChange;

  DetailDateTimePanel({super.key, this.selectedDate, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
            color: CupertinoColors.white,
            fontSize: 16.0,
          )),
        ),
        child: CupertinoDatePicker(
          initialDateTime: selectedDate,
          backgroundColor: const Color(0xFF472478),
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (date) {
            if (onChange != null) {
              onChange!(date);
            }
          },
        ),
      ),
    );
  }
}
