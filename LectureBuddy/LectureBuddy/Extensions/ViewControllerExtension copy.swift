//
//  ViewControllerExtension.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/9/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addDismissKeyboardTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
