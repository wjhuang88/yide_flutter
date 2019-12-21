import 'package:flutter/cupertino.dart';

class AddButtonPositioned extends StatelessWidget {
  const AddButtonPositioned({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Container(
          height: 55.0,
          width: 55.0,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x883D2E75),
                  blurRadius: 10.5,
                  offset: Offset(0.0, 6.5),
                ),
              ]),
          margin: const EdgeInsets.only(right: 10.0, bottom: 20.0),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: const Color(0xFFFAB807),
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            child: const Icon(
              CupertinoIcons.add,
              size: 45.0,
              color: Color(0xFFFFFFFF),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}