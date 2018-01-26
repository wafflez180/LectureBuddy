//
//  NoSubjectsViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/26/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import UIKit

class NoSubjectsViewController: UIViewController {

    var homePageVC: HomePageViewController!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - NoSubjectsViewController
    
    // MARK: - Actions

    @IBAction func pressedViewHighlightingKeywordsButton(_ sender: Any) {
        homePageVC.pressedHighlightKeywordsButton(homePageVC)
    }
    
    @IBAction func pressedAddSubjectButton(_ sender: Any) {
        homePageVC.pressedAddSubjectButton(homePageVC)
    }
}
