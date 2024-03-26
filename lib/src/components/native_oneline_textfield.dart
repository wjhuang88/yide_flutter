import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeOnelineTextField extends StatefulWidget {
  NativeOnelineTextField({
    super.key,
    required this.onSubmitted,
    required this.onChanged,
    required this.placeholder,
    this.text = '',
    this.onFocus,
    this.onUnfocus,
    required this.autofocus,
    required this.controller,
    this.alignment = Alignment.center,
    this.height = 70.0,
  });

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  final String placeholder;
  final String text;
  final bool autofocus;
  final NativeOnelineTextFieldController controller;
  final Alignment alignment;
  final double height;

  @override
  _NativeOnelineTextFieldState createState() =>
      _NativeOnelineTextFieldState(controller);
}

class NativeOnelineTextFieldController {
  late _NativeOnelineTextFieldState _state;

  void focus() {
    _state._focus();
  }

  void unfocus() {
    _state._unfocus();
  }

  void clear() {
    _state._clear();
  }

  String get text => _state._text;
}

class _NativeOnelineTextFieldState extends State<NativeOnelineTextField> {
  _NativeOnelineTextFieldState(this._controller);

  late TextEditingController _textEditingController;
  late FocusNode _focusNode = FocusNode();
  late MethodChannel platform;
  late NativeOnelineTextFieldController _controller;

  late String _text;

  @override
  void initState() {
    super.initState();
    _controller._state = this;
    _textEditingController = widget.text.isNotEmpty
        ? TextEditingController(text: widget.text)
        : TextEditingController();
    _textEditingController.addListener(() {
      _text = _textEditingController.text;
    });
    _text = widget.text;
    platform = const MethodChannel("yide_native_oneline_textfield_view_method");
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onChanged' && call.arguments is String) {
        final text = call.arguments as String;
        _text = text;
        widget.onChanged(text);
      } else if (call.method == 'onSubmitted' && call.arguments is String) {
        final text = call.arguments as String;
        _text = text;
        widget.onSubmitted(text);
      } else if (call.method == 'onFocus' && widget.onFocus != null) {
        widget.onFocus!();
      } else if (call.method == 'onUnfocus' && widget.onUnfocus != null) {
        widget.onUnfocus!();
      }
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onFocus?.call();
      } else {
        widget.onUnfocus?.call();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _focus() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return platform.invokeMethod('focus');
    }
    return FocusScope.of(context).requestFocus(_focusNode);
  }

  Future<void> _unfocus() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return platform.invokeMethod('unfocus');
    }
    return _focusNode.unfocus();
  }

  Future<void> _clear() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return platform.invokeMethod('clear');
    }
    return _controller.clear();
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
          viewType: "yide_native_oneline_textfield_view",
          creationParams: params,
          creationParamsCodec: codec,
        ),
      );
    }
    return CupertinoTextField(
      autofocus: widget.autofocus,
      maxLines: 1,
      cursorWidth: 1.0,
      cursorColor: const Color(0xFFFAB807),
      controller: _textEditingController,
      focusNode: _focusNode,
      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16.0),
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
