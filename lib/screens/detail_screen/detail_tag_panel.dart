import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/models/task_data.dart';

class DetailTagPanel extends StatefulWidget {
  const DetailTagPanel({Key key, this.selectedTag, this.onChange})
      : super(key: key);

  static const panelName = 'detail_tag';

  final TaskTag selectedTag;
  final ValueChanged<TaskTag> onChange;

  @override
  _DetailTagPanelState createState() => _DetailTagPanelState();
}

class _DetailTagPanelState extends State<DetailTagPanel> {
  int _selectedIndex;

  List<TaskTag> _tagList = [
    const TaskTag(id: '0', name: '休息', iconColor: Color(0xFFCFA36F)),
    const TaskTag(id: '1', name: '生活', iconColor: Color(0xFFAF71F5)),
    const TaskTag(id: '2', name: '工作', iconColor: Color(0xFF62DADB)),
    const TaskTag(id: '3', name: '健康', iconColor: Color(0xFFF0DC26)),
  ];

  FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    if (widget.selectedTag != null) {
      final selectedId = widget.selectedTag.id;
      final foundTag = _tagList.firstWhere((item) => item.id == selectedId,
          orElse: () => _tagList.first);
      _selectedIndex = _tagList.indexOf(foundTag);
    } else {
      _selectedIndex = 0;
    }
    _wheelController = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
        child: CupertinoPicker.builder(
          backgroundColor: const Color(0xFF472478),
          itemExtent: 40.0,
          useMagnifier: true,
          magnification: 1.2,
          scrollController: _wheelController,
          itemBuilder: (context, index) => _WheelRow(
            label: _tagList[index].name,
            color: _tagList[index].iconColor,
            selected: _selectedIndex == index,
          ),
          childCount: _tagList.length,
          onSelectedItemChanged: (index) {
            if (_selectedIndex == index) {
              return;
            }
            final callback = widget.onChange;
            if (callback != null) {
              callback(_tagList[index]);
            }
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _WheelRow extends StatelessWidget {
  const _WheelRow({
    Key key,
    @required this.label,
    @required this.color,
    this.selected = false,
  }) : super(key: key);

  final String label;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        selected
            ? Icon(
                FontAwesomeIcons.solidCircle,
                color: color,
                size: 10.0,
              )
            : const SizedBox(
                width: 10.0,
              ),
        const SizedBox(
          width: 14.5,
        ),
        Text(label),
        const SizedBox(
          width: 24.5,
        ),
      ],
    );
  }
}
