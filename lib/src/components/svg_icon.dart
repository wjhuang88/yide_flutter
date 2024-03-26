import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const SvgIcon(
      {super.key,
      required this.asset,
      required this.size,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      height: size,
      width: size,
      color: color,
    );
  }

  static SvgIcon reminder = SvgIcon(
    asset: 'assets/icons/tixing.svg',
    size: 20,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon recurring = SvgIcon(
    asset: 'assets/icons/chongfu.svg',
    size: 20,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon address = SvgIcon(
    asset: 'assets/icons/dizhi.svg',
    size: 20,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon project = SvgIcon(
    asset: 'assets/icons/xiangmu.svg',
    size: 20,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon remark = SvgIcon(
    asset: 'assets/icons/beizhu.svg',
    size: 20,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon config = SvgIcon(
    asset: 'assets/icons/shezhi.svg',
    size: 18,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon plan = SvgIcon(
    asset: 'assets/icons/richen.svg',
    size: 18,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon history = SvgIcon(
    asset: 'assets/icons/rizhi.svg',
    size: 18,
    color: Color(0x88EDE7FF),
  );

  static SvgIcon menu = SvgIcon(
    asset: 'assets/icons/caidan.svg',
    size: 20,
    color: Color(0xFFFFFFFF),
  );
}
