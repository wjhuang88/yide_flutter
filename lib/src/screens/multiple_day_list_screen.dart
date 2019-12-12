import 'package:flutter/cupertino.dart';
import 'package:flutter_tableview/flutter_tableview.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';

class MultipleDayListScreen extends StatefulWidget implements Navigatable {
  @override
  _MultipleDayListScreenState createState() => _MultipleDayListScreenState();

  @override
  Route get route => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => this,
        transitionDuration: Duration(milliseconds: 400),
        transitionsBuilder: (context, anim1, anim2, child) {
          final anim1Curved = CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return Opacity(
            opacity: anim1Curved.value,
            child: child,
          );
        },
      );
}

class _MultipleDayListScreenState extends State<MultipleDayListScreen> {
  bool _isLoadingValue = true;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  ScrollController _scrollController = ScrollController(initialScrollOffset: 30);

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: <Widget>[
            HeaderBar(
              leadingIcon: const Icon(
                CupertinoIcons.left_chevron,
                color: Color(0xFFD7CAFF),
                size: 30.0,
              ),
              actionIcon: _isLoading
                  ? CupertinoActivityIndicator()
                  : const Text(
                      '编辑',
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xFFD7CAFF)),
                    ),
              onLeadingAction: Navigator.of(context).maybePop,
              title: '日程',
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: FlutterTableView(
                  controller: _scrollController,
                  sectionCount: 10,
                  rowCountAtSection: (i) => 3,
                  sectionHeaderBuilder: (context, i) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      color: Color(0xFF000000),
                      child: Text('section: $i'),
                    );
                  },
                  sectionHeaderHeight: (context, i) => 30.0,
                  cellBuilder: (context, section, row) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      color: Color(0xFF888888),
                      child: Text('row $row in section $section'),
                    );
                  },
                  cellHeight: (context, section, row) => 40.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
