//
//  RestartingRecognitionView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/6/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import UIKit

class RestartingRecognitionView: UIView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    var isShowing: Bool {
        get {
            return self.alpha == 1.0
        }
    }
    
    func setupView(){
        self.heightConstraint.constant = 45
        self.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    func show(withSecondsWaiting:Int){
        if isShowing == false {
            animateIn()
        }
        self.titleLabel.text = "\(withSecondsWaiting)s Waiting to restart recognition…"
    }
    
    func animateIn(){
        self.heightConstraint.constant = 90

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 1.0
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateOut(){
        self.heightConstraint.constant = 45
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.titleLabel.text = "0s Waiting to restart recognition…"
        })
    }
}
