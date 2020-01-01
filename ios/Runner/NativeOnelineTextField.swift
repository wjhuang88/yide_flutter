//
//  NativeTextField.swift
//  Runner
//
//  Created by Gerald Huang on 2019/12/29.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
import UIKit
import Flutter

public class NativeOnelineTextField : NSObject, FlutterPlatformView, UITextFieldDelegate {
    
    let _textField: UITextField
    let _channel: FlutterMethodChannel
    
    public init(_ frame: CGRect, channel: FlutterMethodChannel, args: Any?) {
        _textField = UITextField(frame: frame)
        _textField.sizeToFit()
        _textField.returnKeyType = UIReturnKeyType.done
        _textField.font = UIFont.systemFont(ofSize: 16.0)
        _textField.tintColor = UIColor(red: 0.98, green: 0.73333, blue: 0.02745, alpha: 1.0)
        _textField.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        _textField.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        _textField.keyboardAppearance = UIKeyboardAppearance.dark
        _textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        _channel = channel
        
        super.init()
        
        _channel.setMethodCallHandler {[self] (call, result) in
            if "focus" == call.method {
                self._textField.becomeFirstResponder()
                result(nil)
            } else if "unfocus" == call.method {
                self._textField.resignFirstResponder()
                result(nil)
            } else if "clear" == call.method {
                self._textField.text = ""
                result(nil)
            }
        }
        
        if let map = args as? Dictionary<String, Any> {
            if let autofocus = map["autofocus"] as? Bool {
                if autofocus {
                    _textField.becomeFirstResponder()
                }
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
            if let placeholder = map["placeholder"] as? String {
                let label = NSMutableAttributedString(string: placeholder)
                label.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), range: NSMakeRange(0, label.length))
                _textField.attributedPlaceholder = label
            }
        }
        _textField.delegate = self
        _textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }

    @objc func textFieldDidChange(_ textfield : UITextField) {
        _channel.invokeMethod("onChanged", arguments: textfield.text)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        _channel.invokeMethod("onFocus", arguments: nil)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        _channel.invokeMethod("onUnfocus", arguments: nil)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool {
        if text == "\n" {
            textField.resignFirstResponder()
            _channel.invokeMethod("onSubmitted", arguments: textField.text)
            return false
        }
        return true
    }
    
    public func view() -> UIView {
        return _textField
    }
}

public class NativeOnelineTextFieldFactory : NSObject, FlutterPlatformViewFactory {
    public let flutterId = "yide_native_oneline_textfield_view"
    let _messager: FlutterBinaryMessenger
    
    public init(messager: FlutterBinaryMessenger) {
        _messager = messager
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(name: flutterId + "_method", binaryMessenger: _messager)
        return NativeOnelineTextField(frame, channel: channel, args: args)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}
