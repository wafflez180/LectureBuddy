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

class AddSubjectPopupView: UIView, PopupViewProtocol {

    // MARK: - PopupViewProtocol
    
    class func instanceFromNib() -> PopupTemplateView {
        let popupContentNib = UINib(nibName: "AddSubjectPopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AddSubjectPopupView
        let popupTemplateNib = PopupTemplateView.instanceFromNib()
        popupTemplateNib.addContentView(view: popupContentNib)
        return popupTemplateNib
    }
    
    func pressedMainButton(activityIndicator: NVActivityIndicatorView, success: @escaping () -> Void, error: @escaping () -> Void) {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 2.0, delay: 2.0, options: .curveEaseIn, animations: {
            
        }) { completion in
            success()
            print("completion")
        }
        print("AddSubjectPopupView")
    }

    // MARK: - AddSubjectPopupView
}
