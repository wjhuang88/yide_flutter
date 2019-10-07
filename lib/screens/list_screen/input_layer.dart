import 'package:flutter/material.dart';

class InputLayer extends StatelessWidget {
  const InputLayer({
    Key key,
    this.backgroundOpacity = 0.5,
    this.isShow = true,
    this.panelColor = Colors.white,
    this.panelHeightFactor = 1.0,
    this.panelOpacity = 1.0,
    this.onCancel,
    this.focusNode,
  }) : super(key: key);

  final double backgroundOpacity;
  final bool isShow;
  final Color panelColor;
  final double panelHeightFactor;
  final double panelOpacity;
  final void Function() onCancel;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isShow,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(backgroundOpacity),
          child: Opacity(
            opacity: panelOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (focusNode != null) {
                        focusNode.unfocus();
                      } else {
                        FocusScope.of(context).unfocus();
                      }
                      if (onCancel != null) {
                        onCancel();
                      }
                    },
                    child: Container(),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, 130 * (1.0 - panelHeightFactor), 0.0),
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        offset: const Offset(0.0, 1.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        color: Colors.grey[500],
                      )
                    ],
                  ),
                  child: TextField(
                    focusNode: focusNode,
                    maxLines: null,
                    maxLength: 140,
                    style: TextStyle(fontSize: 16,),
                    decoration: InputDecoration(
                      hintText: '输入内容',
                      contentPadding: EdgeInsets.fromLTRB(20, 10.0, 20, 10.0),
                      border: InputBorder.none,
                      //focusedBorder: OutlineInputBorder()
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  color: panelColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('取消'),
                        onPressed: () {},
                      ),
                      _buildVertDivider(),
                      FlatButton.icon(
                        icon: Icon(Icons.more_horiz),
                        label: Text('更多'),
                        onPressed: () {},
                      ),
                      _buildVertDivider(),
                      FlatButton.icon(
                        icon: Icon(Icons.check),
                        label: Text('确定'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildVertDivider() {
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey)
        )
      ),
    ),
  );
}