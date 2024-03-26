import 'package:flutter/cupertino.dart';

class DetailTimePanel extends StatelessWidget {
  static const panelName = 'detail_time';

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onChange;

  DetailTimePanel({super.key, this.selectedDate, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
            color: CupertinoColors.white,
            fontSize: 20.0,
          )),
        ),
        child: CupertinoDatePicker(
          initialDateTime: selectedDate,
          use24hFormat: true,
          backgroundColor: const Color(0xFF472478),
          mode: CupertinoDatePickerMode.time,
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
