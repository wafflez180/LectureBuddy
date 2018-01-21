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

class SaveRecordingPopupView: PopupContentView, PopupViewProtocol {
    
    @IBOutlet var recordingTitleTextField: UITextField!
    
    var initialTitle:String

    /*init(initialTitle: String) {
        self.initialTitle = initialTitle
        
        super.init()
    }
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PopupViewProtocol
    
    func popupDidAppear() {
        recordingTitleTextField.becomeFirstResponder()
        
        recordingTitleTextField.text = initialTitle
    }
    
    func getTitle() -> String {
        return "Save Recording"
    }
    
    func getButtonTitle() -> String {
        return "Save"
    }
            
    func pressedMainButton(success: @escaping () -> Void, error: @escaping (_ alert:UIAlertController?) -> Void, doNothing: @escaping () -> Void) {
        if (recordingTitleTextField.text != ""){
            success()
            
            //viewController.dismiss(animated: true, completion: nil)
//            DataManager.sharedInstance.saveNewSubject(subjectName: recordingTitleTextField.text!, success: {
//                success()
//            }
        }else{
            error(nil)
        }
    }
    
    // MARK: - SaveRecordingPopupView
}
