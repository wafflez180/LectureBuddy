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
    
    func getTitle() -> String {
        return "Add New Subject"
    }
    
    func getButtonTitle() -> String {
        return "Add"
    }
            
    func pressedMainButton(success: @escaping () -> Void, error: @escaping () -> Void) {
        if (subjectTextField.text != ""){
            DataManager.sharedInstance.saveNewSubject(subjectName: subjectTextField.text!, success: {
                success()
            }) {
                // Subject exists error
                print("Error: Subject Exists")
            }
            print("AddSubjectPopupView")
        }else{
            error()
        }
    }
    
    // MARK: - AddSubjectPopupView
}
