//
//  AddSubjectPopupView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit

class AddSubjectPopupView: UIView, PopupViewProtocol {
    
    // MARK: - PopupViewProtocol
    
    class func instanceFromNib() -> PopupTemplateView {
        let popupContentNib = UINib(nibName: "AddSubjectPopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AddSubjectPopupView
        let popupTemplateNib = PopupTemplateView.instanceFromNib()
        popupTemplateNib.addContentView(view: popupContentNib)
        return popupTemplateNib
    }
    
    func pressedMainButton() {
        print("AddSubjectPopupView------adwdawdawdwad--a---aw-d-awd-ad")
    }

    // MARK: - AddSubjectPopupView
}
