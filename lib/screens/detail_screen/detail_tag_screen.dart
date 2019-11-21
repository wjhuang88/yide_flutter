import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/models/task_data.dart';

class DetailTagScreen extends StatefulWidget {
  static const String routeName = 'detail_tag';

  const DetailTagScreen({Key key, this.selectedTag}) : super(key: key);
  static Route pageRoute(dynamic args) => _buildRoute(args);

  final TaskTag selectedTag;

  @override
  _DetailTagScreenState createState() => _DetailTagScreenState();
}

class _DetailTagScreenState extends State<DetailTagScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFF8346C8),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.times,
            color: Color(0xFFD7CAFF),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '标签',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () => Navigator.of(context)
                .maybePop<TaskTag>(_tagList[_selectedIndex]),
          ),
        ],
      ),
      body: Container(
        height: 300.0,
        margin: const EdgeInsets.only(top: 100.0),
        child: CupertinoTheme(
          data: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              pickerTextStyle: TextStyle(fontSize: 25.0, color: Colors.white),
            ),
          ),
          child: CupertinoPicker.builder(
            backgroundColor: const Color(0xFF8346C8),
            itemExtent: 50.0,
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
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
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
                size: 11.0,
              )
            : const SizedBox(
                width: 11.0,
              ),
        const SizedBox(
          width: 14.5,
        ),
        Text(label),
      ],
    );
  }
}

_buildRoute(dynamic args) {
  var generatedWidget;
  if (args is TaskTag) {
    generatedWidget = DetailTagScreen(
      selectedTag: args,
    );
  } else {
    generatedWidget = DetailTagScreen();
  }
  return PageRouteBuilder<TaskTag>(
    pageBuilder: (context, anim1, anim2) => generatedWidget,
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        ),
      );
      return FractionalTranslation(
        translation: Offset(0.0, 1 - anim1Curved.value),
        child: Opacity(
          opacity: anim1Curved.value,
          child: child,
        ),
      );
    },
  );
}
