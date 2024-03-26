import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';

class DetailTagPanel extends StatefulWidget {
  const DetailTagPanel({super.key, this.selectedTag, this.onChange});

  static const panelName = 'detail_tag';

  final TaskTag? selectedTag;
  final ValueChanged<TaskTag>? onChange;

  @override
  _DetailTagPanelState createState() => _DetailTagPanelState();
}

class _DetailTagPanelState extends State<DetailTagPanel> {
  late int _selectedIndex;

  Future<List<TaskTag>?> _tagListFuture = TaskDBAction.getAllTaskTag();
  static List<TaskTag>? _initList = [const TaskTag.defaultNull()];

  late FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskTag>?>(
      future: _tagListFuture,
      initialData: _initList,
      builder: (context, snap) {
        final _tagList = _initList = snap.data;
        if (widget.selectedTag != null) {
          final selectedId = widget.selectedTag?.id;
          final foundTag = _tagList?.firstWhere((item) => item.id == selectedId,
              orElse: () => _tagList.first);
          _selectedIndex =
              _tagList?.indexOf(foundTag ?? TaskTag.defaultNull()) ?? 0;
        } else {
          _selectedIndex = 0;
        }
        _wheelController =
            FixedExtentScrollController(initialItem: _selectedIndex);

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
                label: _tagList?[index].name ?? '',
                color: _tagList?[index].iconColor ?? const Color(0xFFF),
                selected: _selectedIndex == index,
              ),
              childCount: _tagList?.length ?? 0,
              onSelectedItemChanged: (index) {
                if (_selectedIndex == index) {
                  return;
                }
                final callback = widget.onChange;
                if (callback != null) {
                  callback(_tagList?[index] ?? TaskTag.defaultNull());
                }
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class _WheelRow extends StatelessWidget {
  const _WheelRow({
    super.key,
    required this.label,
    required this.color,
    this.selected = false,
  });

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
