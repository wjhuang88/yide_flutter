import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/mixins/navigatable_menu_side.dart';
import 'package:yide/src/notification.dart';

class AboutScreen extends StatelessWidget with NavigatableMenuSide {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.6;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            HeaderBar(
              actionIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '返回',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: const Color(0xFFEDE7FF),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.right_chevron,
                    size: 26.0,
                    color: const Color(0xFFEDE7FF),
                  ),
                ],
              ),
              onAction: () =>
                  PopRouteNotification(isSide: true).dispatch(context),
              title: name,
            ),
            Container(
              height: height,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    FontAwesomeIcons.oldRepublic,
                    size: 130.0,
                    color: Color(0xFFFFFFFF),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Text(
                    '壹得 YeeDe',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 20.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    'Version 0.1.10',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '版权所有 © 2019 霖森科技，保留所有权利。',
                      style: TextStyle(
                        color: Color(0x88FFFFFF),
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      'Copyright © 2019 Lindenz. All Rights Reserved.',
                      style: TextStyle(
                        color: Color(0x88FFFFFF),
                        fontSize: 14.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CupertinoButton(
                          child: Text(
                            '服务条款',
                            style: TextStyle(
                              color: Color(0x88FFFFFF),
                              fontSize: 14.0,
                            ),
                          ),
                          onPressed: () {
                            _showWeb(
                              context,
                              'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                              title: '服务条款',
                            );
                          },
                        ),
                        CupertinoButton(
                          child: Text(
                            '隐私策略',
                            style: TextStyle(
                              color: Color(0x88FFFFFF),
                              fontSize: 14.0,
                            ),
                          ),
                          onPressed: () {
                            _showWeb(
                              context,
                              'http://www.lindenz.com',
                              title: '隐私策略',
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _showWeb(BuildContext context, String url, {String title, Color headerColor}) {
    return showCupertinoModalPopup(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return Container(
          color: headerColor ?? const Color(0xFF333333),
          child: Column(
            children: <Widget>[
              HeaderBar(
                title: title,
                leadingIcon: const Icon(
                  CupertinoIcons.clear,
                  color: Color(0xFFF5F5F7),
                  size: 40.0,
                ),
                onLeadingAction: Navigator.of(context).maybePop,
              ),
              Expanded(
                child: WebView(
                  initialUrl: url,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  String get name => '关于我们';
}
