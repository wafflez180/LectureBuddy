//
//  PopupTemplateViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/9/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Spring
import NVActivityIndicatorView

protocol PopupViewProtocol: class {
    func getTitle() -> String
    func getButtonTitle() -> String
    func pressedMainButton(success: @escaping () -> Void, error: @escaping () -> Void)
}

class PopupTemplateViewController: UIViewController {

    @IBOutlet var popupView: SpringView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mainButton: UIButton!
    @IBOutlet var contentContainerView: UIView!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    weak var delegate: PopupViewProtocol?
    var contentView:UIView!
    var popupTitle:String!
    var buttonTitle:String!

    // MARK: - PopupTemplateViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentPopup()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - PopupTemplateView
    
    func setUI(contentView: UIView, popupTitle: String, buttonTitle:String){
        self.contentView = contentView
        self.delegate = contentView as? PopupViewProtocol
        self.popupTitle = popupTitle
        self.buttonTitle = buttonTitle
    }
    
    func configureUI(){
        self.view.alpha = 0.0
        addContentView()
        mainButton.roundCorners([.bottomLeft, .bottomRight], radius: popupView.cornerRadius)
        titleLabel.text = popupTitle
        mainButton.setTitle(buttonTitle, for: .normal)
    }
    
    func addContentView(){
        // Change height of contentContainerView
        contentViewHeightConstraint.constant = contentView.frame.size.height
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        
        contentContainerView.addSubview(contentView)
        // Change frame of contentView to fit inside the contentContainerView
        var newFrame = contentView.frame
        newFrame.origin = CGPoint(x: 0, y: 0)
        newFrame.size.width = contentContainerView.frame.size.width
        contentView.frame = newFrame
        
        self.view.layoutIfNeeded()
    }
    
    func presentPopup() {
        // Animate Popup In
        popupView.animate()
        // Fade In
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }
    
    func dismissPopup() {
        // Fade Out
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.alpha = 0.0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressedDismissButton(_ sender: Any) {
        dismissPopup()
        print("pressedDismissButton")
    }
    
    @IBAction func pressedMainButton(_ sender: Any) {
        mainButton.isSelected = true
        activityIndicator.startAnimating()
        delegate?.pressedMainButton(success: {
            self.dismissPopup()
        }, error: {
            print("Popup Error")
            self.activityIndicator.stopAnimating()
            self.mainButton.isSelected = false
        })
    }
    
    @IBAction func tappedOnView(_ sender: Any) {
        // Hide Keyboard
        self.view.endEditing(true)
    }
}
