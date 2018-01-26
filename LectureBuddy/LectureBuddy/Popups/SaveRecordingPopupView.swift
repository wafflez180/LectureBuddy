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

protocol SaveRecordingPopupProtocol: class {
    func willDismissPopup()
}

class SaveRecordingPopupView: PopupContentView, PopupViewProtocol {
    
    @IBOutlet var recordingTitleTextField: UITextField!
    
    static var initialTitleFieldText: String = ""
    static var textToSave: String!
    static var subject: Subject!

    static var delegate: SaveRecordingPopupProtocol?

    // MARK: - PopupViewProtocol
    
    func popupDidAppear() {
        recordingTitleTextField.text = SaveRecordingPopupView.initialTitleFieldText

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.recordingTitleTextField.text == "Untitled" {
                self.recordingTitleTextField.selectAll(nil)
            }
            self.recordingTitleTextField.becomeFirstResponder()
        }
    }
    
    func getTitle() -> String {
        return "Save Recording"
    }
    
    func getButtonTitle() -> String {
        return "Save"
    }
            
    func pressedMainButton(success: @escaping () -> Void, error: @escaping (_ alert:UIAlertController?) -> Void, doNothing: @escaping () -> Void) {
        if (recordingTitleTextField.text != ""){
            self.endEditing(true)
            
            let recordingToSave = Recording.init(title: recordingTitleTextField.text!, text: SaveRecordingPopupView.textToSave)
            
            DataManager.sharedInstance.saveNewRecording(subject: SaveRecordingPopupView.subject, recording: recordingToSave, success: {
                SaveRecordingPopupView.delegate?.willDismissPopup()
                success()
            })
        }else{
            error(nil)
        }
    }
    
    // MARK: - SaveRecordingPopupView
}
