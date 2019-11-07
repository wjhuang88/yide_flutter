import 'package:flutter/material.dart';

class EditMainScreen extends StatelessWidget {

  static const String routeName = 'new';
  static Route get pageRoute => _buildRoute(EditMainScreen());

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff37256d),
      body: Container(
        color: const Color(0xff5a4791),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                decoration: const BoxDecoration(
                  color: Color(0xff634f9f),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20.0,
                      offset: Offset(0.0, 5.0),
                      color: Color(0x55000000),
                    ),
                  ]
                ),
                child: TextField(
                  autofocus: true,
                  minLines: 3,
                  maxLines: 4,
                  controller: _textEditingController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '记录你今天的任务',
                    hintStyle: TextStyle(color: Color(0xff7863b5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 40.0,),
              Text('今天', style: const TextStyle(color: Colors.white, fontSize: 24.0),),
              Text('11月6日', style: const TextStyle(color: Color(0xffbbade7), fontSize: 16.0),),
              const Expanded(
                child: SizedBox.expand(),
              ),
              Container(
                color: const Color(0xff37256d),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: const Text('设置时间', style: TextStyle(color: Color(0xffbbade7)),),
                      onPressed: (){},
                    ),
                    const _VerticleDivider(),
                    FlatButton(
                      child: const Text('全天', style: TextStyle(color: Color(0xffbbade7)),),
                      onPressed: (){},
                    ),
                    const _VerticleDivider(),
                    FlatButton(
                      child: const Text('保存', style: TextStyle(color: Color(0xffbbade7)),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 1000),
    transitionsBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(
            parent: anim1,
            curve: Cubic(0,1,.55,1),
          ),
        ),
        child: child,
      );
    },
  );
}

class _VerticleDivider extends StatelessWidget {
  const _VerticleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: Color(0xffbbade7))
          )
      ),
    );
  }
}