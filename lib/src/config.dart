import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/components/svg_icon.dart';
import 'package:yide/src/screens/history_list_screen.dart';
import 'package:yide/src/screens/multiple_day_list_screen.dart';

import 'setup_screen.dart';

const backgroundGradient = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF8346C8), Color(0xFF523F88)],
);

const finishedColor = const Color(0x88C9A2F5);

final listPlaceholder = Image.asset(
  'assets/images/placeholder.png',
  fit: BoxFit.contain,
);

final mainNavigatorKey = GlobalKey<NavigatorState>();
final sideNavigatorKey = GlobalKey<NavigatorState>();

final menuConfig = [
  [
    {
      'name': '今日',
      'route': null,
      'icon': const Icon(
        FontAwesomeIcons.solidStar,
        size: 18.0,
        color: Color(0x88EDE7FF),
      ),
      'level': 0,
      'side': false,
    },
    {
      'name': '计划',
      'route': () => MultipleDayListScreen(),
      'icon': SvgIcon.plan,
      'level': 0,
      'side': false,
    },
    {
      'name': '日志',
      'route': () => HistoryListScreen(),
      'icon': SvgIcon.history,
      'level': 0,
      'side': false,
    },
  ],
  // [
  //   {
  //     'name': '添加项目',
  //     'route': null,
  //     'icon': const Icon(
  //       FontAwesomeIcons.plusCircle,
  //       size: 18.0,
  //       color: Color(0x88EDE7FF),
  //     ),
  //     'level': 0,
  //     'side': false,
  //   },
  //   {
  //     'name': '项目一',
  //     'route': null,
  //     'icon': const Icon(
  //       FontAwesomeIcons.minusCircle,
  //       size: 18.0,
  //       color: Color(0x88EDE7FF),
  //     ),
  //     'level': 1,
  //     'side': false,
  //   },
  //   {
  //     'name': '项目二',
  //     'route': null,
  //     'icon': const Icon(
  //       FontAwesomeIcons.minusCircle,
  //       size: 18.0,
  //       color: Color(0x88EDE7FF),
  //     ),
  //     'level': 1,
  //     'side': false,
  //   },
  // ],
  [
    {
      'name': '设置',
      'route': () => SetupScreen(),
      'icon': SvgIcon.config,
      'level': 0,
      'side': true,
    },
  ]
];
