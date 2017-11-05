//
//  PopupTemplateView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

protocol PopupViewProtocol: class {
    func pressedMainButton()
}

@IBDesignable class PopupTemplateView: UIView {
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mainButton: UIButton!
    @IBOutlet var contentContainerView: UIView!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: PopupViewProtocol?
    var contentView:UIView!
    
    // MARK: - NIB/XIB

    class func instanceFromNib() -> PopupTemplateView {
        return UINib(nibName: "PopupTemplateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PopupTemplateView
    }

    // MARK: - PopupTemplateView
    
    func addContentView(view: UIView){
        contentView = view
        // Change height of contentContainerView
        contentViewHeightConstraint.constant = contentView.frame.size.height
        self.updateConstraints()
        self.layoutIfNeeded()

        delegate = contentView as? PopupViewProtocol
        contentContainerView.addSubview(contentView)
        // Change frame of contentView to fit inside the contentContainerView
        var newFrame = contentView.frame
        newFrame.origin = CGPoint(x: 0, y: 0)
        newFrame.size.width = contentContainerView.frame.size.width
        contentView.frame = newFrame
        
        self.layoutIfNeeded()
    }
    
    func presentPopup(title: String, buttonTitle:String) {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        mainButton.roundCorners([.bottomLeft, .bottomRight], radius: popupView.cornerRadius)
        titleLabel.text = title
        mainButton.setTitle(buttonTitle, for: .normal)
        // Fade In
        self.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }

    func dismissPopup() {
        // Fade Out
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressedDismissButton(_ sender: Any) {
        dismissPopup()
        print("pressedDismissButton")
    }
    
    @IBAction func pressedMainButton(_ sender: Any) {
        delegate?.pressedMainButton()
        print("pressedMainButton")
    }
}
