//
//  PopupContentView.swift
//  Bolts
//
//  Created by Arthur De Araujo on 11/9/17.
//

import UIKit

class PopupContentView: UIView {
    
    func present(viewController: UIViewController, popupTitle:String, buttonTitle:String) {
        // Instantiate popup contentView
        let className = String(describing: type(of: self))
        print("Presenting the " + className)
        let contentView = UINib(nibName: className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PopupViewProtocol
        // Instantiate popup templateView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupTemplateVC = storyboard.instantiateViewController(withIdentifier: "PopupVCId") as! PopupTemplateViewController
        popupTemplateVC.setUI(contentView: contentView as! UIView, popupTitle: contentView.getTitle(), buttonTitle: contentView.getButtonTitle())
        // Present
        viewController.present(popupTemplateVC, animated: false, completion: nil)
    }
}

