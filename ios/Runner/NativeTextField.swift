//
//  NativeTextField.swift
//  Runner
//
//  Created by Gerald Huang on 2019/12/29.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
import UIKit
import Flutter
import UITextView_Placeholder

public class NativeTextField : NSObject, FlutterPlatformView, UITextViewDelegate {
    
    let _textField: UITextView
    let _channel: FlutterMethodChannel
    
    public init(_ frame: CGRect, channel: FlutterMethodChannel, args: Any?) {
        _textField = UITextView(frame: frame)
        _textField.sizeToFit()
        _textField.returnKeyType = UIReturnKeyType.done
        _textField.font = UIFont.systemFont(ofSize: 16.0)
        _textField.tintColor = UIColor(red: 0.98, green: 0.73333, blue: 0.02745, alpha: 1.0)
        _textField.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        _textField.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        _textField.keyboardAppearance = UIKeyboardAppearance.dark
        
        _channel = channel
        
        super.init()
        
        _channel.setMethodCallHandler {[self] (call, result) in
            if "focus" == call.method {
                self._textField.becomeFirstResponder()
                result(nil)
            } else if "unfocus" == call.method {
                self._textField.resignFirstResponder()
                result(nil)
            }
        }
        
        if let map = args as? Dictionary<String, Any> {
            if let autofocus = map["autofocus"] as? Bool {
                if autofocus {
                    _textField.becomeFirstResponder()
                }
            }
            if let placeholder = map["placeholder"] as? String {
                _textField.placeholder = placeholder
                _textField.placeholderColor = UIColor(red: 0.61, green: 0.498, blue: 0.9137, alpha: 1.0)
            }
            if let text = map["text"] as? String {
                if !text.isEmpty {
                    _textField.text = text
                }
            }
            if let align = map["alignment"] as? Int {
                if align == 2 {
                    _textField.textAlignment = NSTextAlignment.right
                } else if align == 1 {
                    _textField.textAlignment = NSTextAlignment.center
                } else {
                    _textField.textAlignment = NSTextAlignment.left
                }
            }
        }
        _textField.delegate = self
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        _channel.invokeMethod("onChanged", arguments: textView.text)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        _channel.invokeMethod("onFocus", arguments: nil)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        _channel.invokeMethod("onUnfocus", arguments: nil)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            _channel.invokeMethod("onSubmitted", arguments: textView.text)
            return false
        }
        return true
    }
    
    public func view() -> UIView {
        return _textField
    }
}

public class NativeTextFieldFactory : NSObject, FlutterPlatformViewFactory {
    public let flutterId = "yide_native_textfield_view"
    let _messager: FlutterBinaryMessenger
    
    public init(messager: FlutterBinaryMessenger) {
        _messager = messager
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(name: flutterId + "_method", binaryMessenger: _messager)
        return NativeTextField(frame, channel: channel, args: args)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}
