import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/screens/multiple_day_list_screen.dart';

import 'screens/feedback_screen.dart';

const backgroundGradient = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF8346C8), Color(0xFF523F88)],
);

final navigateKey = GlobalKey<NavigatorState>();

final menuConfig = [
  [
    {
      'name': '今天',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.solidStar, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
    {
      'name': '日程',
      'route': () => MultipleDayListScreen(),
      'icon': const Icon(FontAwesomeIcons.calendar, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
    // {
    //   'name': '收集箱',
    //   'route': null,
    //   'icon': const Icon(FontAwesomeIcons.inbox, size: 20.0),
    //   'level': 0
    // },
  ],
  [
    {
      'name': '添加项目',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.plusCircle, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
    {
      'name': '项目一',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.minusCircle, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 1
    },
    {
      'name': '项目二',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.minusCircle, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 1
    },
  ],
  [
    {
      'name': '归档内容',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.archive, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
    {
      'name': '更多推荐',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.ellipsisH, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
    {
      'name': '建议反馈',
      'route': () => FeedbackScreen(),
      'icon': const Icon(FontAwesomeIcons.solidCommentDots, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
  ],
  [
    {
      'name': '设置',
      'route': null,
      'icon': const Icon(FontAwesomeIcons.cogs, size: 18.0, color: Color(0xFFEDE7FF),),
      'level': 0
    },
  ]
];
