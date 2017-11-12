//
//  AddSubjectPopupView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Firebase

class AddSubjectPopupView: PopupContentView, PopupViewProtocol {
    
    @IBOutlet var subjectTextField: UITextField!
    
    // MARK: - PopupViewProtocol
    
    func popupDidAppear() {
        subjectTextField.becomeFirstResponder()
    }
    
    func getTitle() -> String {
        return "Add New Subject"
    }
    
    func getButtonTitle() -> String {
        return "Add"
    }
            
    func pressedMainButton(success: @escaping () -> Void, error: @escaping (_ alert:UIAlertController?) -> Void, doNothing: @escaping () -> Void) {
        if (subjectTextField.text != ""){
            DataManager.sharedInstance.saveNewSubject(subjectName: subjectTextField.text!, success: {
                success()
            }) {
                // Subject exists error
                print("Error: Subject Exists")
                error(self.getSubjectExistsAlert())
            }
            print("AddSubjectPopupView")
        }else{
            error(nil)
        }
    }
    
    // MARK: - AddSubjectPopupView
    
    func getSubjectExistsAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: "A subject with that name already exists", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
}
