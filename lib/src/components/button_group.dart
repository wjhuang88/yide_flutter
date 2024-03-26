import 'package:flutter/material.dart';

class ButtonGroup extends StatelessWidget {
  final Color color;
  final Color textColor;
  final Map<String, VoidCallback> dataSet;
  final double height;
  final double width;
  final int _count;

  const ButtonGroup({
    required Key key,
    required this.color,
    required this.textColor,
    required this.dataSet,
    required this.height,
    required this.width,
  })  : assert(dataSet.length > 0),
        _count = dataSet.length,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_count == 1) {
      final item = dataSet.entries.first;
      return _buildContainer(item.key, item.value, _Type.single);
    }

    final divider = SizedBox(
      width: 1.0,
    );
    final it = dataSet.entries.iterator;
    var count = 0;
    it.moveNext();
    final first = it.current;
    final children = [
      _buildContainer(first.key, first.value, _Type.first),
      divider
    ];
    while (count++ < _count - 1 && it.moveNext()) {
      if (count < _count - 1) {
        var item = it.current;
        children
          ..add(_buildContainer(item.key, item.value, _Type.normal))
          ..add(divider);
      }
    }
    final last = it.current;
    children.add(_buildContainer(last.key, last.value, _Type.last));

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  Widget _buildContainer(String text, VoidCallback action, _Type type) {
    BorderRadius radius;
    switch (type) {
      case _Type.first:
        {
          radius = BorderRadius.only(
            topLeft: Radius.circular(height / 2),
            bottomLeft: Radius.circular(height / 2),
          );
          break;
        }
      case _Type.normal:
        {
          radius = BorderRadius.zero;
          break;
        }
      case _Type.last:
        {
          radius = BorderRadius.only(
            topRight: Radius.circular(height / 2),
            bottomRight: Radius.circular(height / 2),
          );
          break;
        }
      case _Type.single:
        {
          radius = BorderRadius.circular(height / 2);
        }
    }

    return GestureDetector(
      onTap: action,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: (width - _count + 1) / _count,
        child: Text(text, style: TextStyle(color: textColor)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
        ),
      ),
    );
  }
}

enum _Type { first, normal, last, single }
