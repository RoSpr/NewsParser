//
//  Utils.swift
//  NewsParser
//
//  Created by Rodion on 28.12.2024.
//

import Foundation
import UIKit

struct Utils {
    static func getDateFromString(_ string: String?, format: String = "E, dd MMM yyyy HH:mm:ss Z") -> Date? {
        guard let string = string else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        return formatter.date(from: string)
    }
    
    static func getStringFromDate(_ date: Date?, format: String = "dd-MM-yyyy, HH:mm") -> String? {
        guard let date else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func makePopUp(parent: UIViewController?, title: String?, message: String?, actionTitle: String, actionStyle: UIAlertAction.Style, cancelTitle: String? = nil, actionHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: { _ in
            actionHandler?()
        })
        controller.addAction(action)
        
        var cancelAction: UIAlertAction?
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
                cancelHandler?()
            })
            controller.addAction(cancelAction!)
        }
        
        var parentVC = parent
        if parentVC == nil {
            parentVC = UIApplication.topViewController()
        }
        
        guard let parentVC = parentVC else { return }
        parentVC.present(controller, animated: true)
    }

    static func addPopupWithTextfield(parent: UIViewController, title: String?, message: String?, textfieldDelegate: UITextFieldDelegate?, actionTitle: String, actionStyle: UIAlertAction.Style, cancelTitle: String?, actionHandler: (() -> Void)?, cancelHandler: (() -> Void)?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        controller.addTextField() { textfield in
            textfield.delegate = textfieldDelegate
            textfield.placeholder = "Enter_url".localized()
        }
        
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: { _ in
            actionHandler?()
        })
        controller.addAction(action)
        
        var cancelAction: UIAlertAction?
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
                cancelHandler?()
            })
            controller.addAction(cancelAction!)
        }
        
        parent.present(controller, animated: true)
    }
    
    static func convertBytesToString(_ bytes: Int) -> String {
        let kb = Float(bytes) / 1024
        let mb = kb / 1024
        let gb = mb / 1024
        
        if bytes < 1024 {
            return "bytes".localized(String(format: "%.2f", bytes))
        } else if kb < 1024 {
            return "kilobytes".localized(String(format: "%.2f", kb))
        } else if mb < 1024 {
            return "megabytes".localized(String(format: "%.2f", mb))
        } else if gb < 1024 {
            return "gigabytes".localized(String(format: "%.2f", gb))
        }
        return ""
    }
}
