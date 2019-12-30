import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeTextField extends StatefulWidget {
  NativeTextField({
    Key key,
    this.onSubmitted,
    this.onChanged,
    this.placeholder,
    this.text,
    this.onFocus,
    this.onUnfocus,
    this.autofocus,
    this.controller,
    this.alignment = Alignment.center,
    this.height = 70.0,
  }) : super(key: key);

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocus;
  final VoidCallback onUnfocus;
  final String placeholder;
  final String text;
  final bool autofocus;
  final NativeTextFieldController controller;
  final Alignment alignment;
  final double height;

  @override
  _NativeTextFieldState createState() => _NativeTextFieldState(controller);
}

class NativeTextFieldController {
  _NativeTextFieldState _state;

  void focus() {
    _state?._focus();
  }

  void unfocus() {
    _state?._unfocus();
  }

  String get text => _state?._text;
}

class _NativeTextFieldState extends State<NativeTextField> {
  _NativeTextFieldState(this._controller);

  TextEditingController _textEditingController;
  FocusNode _focusNode = FocusNode();
  MethodChannel platform;
  NativeTextFieldController _controller;

  String _text;

  @override
  void initState() {
    super.initState();
    _controller ??= NativeTextFieldController();
    _controller._state = this;
    _textEditingController = widget.text != null && widget.text.isNotEmpty
        ? TextEditingController(text: widget.text)
        : TextEditingController();
    _textEditingController.addListener(() {
      _text = _textEditingController.text;
    });
    _text = widget.text ?? '';
    platform = const MethodChannel("yide_native_textfield_view_method");
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onChanged' && call.arguments is String) {
        if (widget.onChanged != null) {
          final text = call.arguments as String;
          _text = text;
          widget.onChanged(text);
        }
      } else if (call.method == 'onSubmitted' && call.arguments is String) {
        if (widget.onSubmitted != null) {
          final text = call.arguments as String;
          _text = text;
          widget.onSubmitted(text);
        }
      } else if (call.method == 'onFocus') {
        if (widget.onFocus != null) {
          widget.onFocus();
        }
      } else if (call.method == 'onUnfocus') {
        if (widget.onUnfocus != null) {
          widget.onUnfocus();
        }
      }
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (widget.onFocus != null) {
          widget.onFocus();
        }
      } else {
        if (widget.onUnfocus != null) {
          widget.onUnfocus();
        }
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _focus() {
    return platform.invokeMethod('focus');
  }

  Future<void> _unfocus() {
    return platform.invokeMethod('unfocus');
  }

  int _getAlignCode() {
    final align = widget.alignment;
    return align == Alignment.centerLeft ||
            align == Alignment.topLeft ||
            align == Alignment.bottomLeft
        ? 0
        : align == Alignment.topCenter ||
                align == Alignment.bottomCenter ||
                align == Alignment.center
            ? 1
            : 2;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final codec = const StandardMessageCodec();
      final params = <String, dynamic>{
        "autofocus": widget.autofocus,
        "placeholder": widget.placeholder,
        "text": widget.text,
        "alignment": _getAlignCode(),
      };
      return Container(
        height: widget.height,
        child: UiKitView(
          viewType: "yide_native_textfield_view",
          creationParams: params,
          creationParamsCodec: codec,
        ),
      );
    }
    return CupertinoTextField(
      autofocus: widget.autofocus,
      minLines: 1,
      maxLines: 3,
      cursorWidth: 1.0,
      cursorColor: const Color(0xFFFAB807),
      controller: _textEditingController,
      focusNode: _focusNode,
      style: const TextStyle(
          color: Color(0xFFFFFFFF), fontSize: 16.0, height: 1.5),
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      keyboardAppearance: Brightness.dark,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      placeholder: widget.placeholder,
      placeholderStyle: const TextStyle(color: Color(0xFF9B7FE9)),
      decoration: const BoxDecoration(color: Color(0x00000000)),
    );
  }
}
