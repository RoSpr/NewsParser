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
        
        return formatter.date(from: string)
    }
    
    static func getStringFromDate(_ date: Date?, format: String = "dd-MM-yyyy, HH:mm") -> String? {
        guard let date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func makePopUp(parent: UIViewController, title: String?, message: String?, actionTitle: String, actionStyle: UIAlertAction.Style, cancelTitle: String?, actionHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: actionHandler)
        controller.addAction(action)
        
        var cancelAction: UIAlertAction?
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler)
            controller.addAction(cancelAction!)
        }
        
        parent.present(controller, animated: true)
    }
}
