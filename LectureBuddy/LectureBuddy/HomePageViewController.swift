//
//  HomePageViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/22/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Pageboy
import Tabman
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class HomePageViewController: TabmanViewController, PageboyViewControllerDataSource {
    
    let subjectDocs = DataManager.sharedInstance.subjectDocs
    var viewControllers:[UIViewController] = []
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.dataSource = self
        
        setupSubjects()
        configureTabBar()
    }
    
    // MARK: - HomePageViewController
    
    func configureTabBar(){
        addTabBarItems()
        
        // Appearance property list: https://github.com/uias/Tabman/blob/master/Docs/APPEARANCE.md
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.style.background = TabmanBar.BackgroundView.Style.solid(color: ColorManager.purple)

            appearance.text.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            
            appearance.indicator.color = .white
            appearance.indicator.lineWeight = TabmanIndicator.LineWeight.thick
            
            appearance.state.color = ColorManager.lightPurple
            appearance.state.selectedColor = .white
        })

    }
    
    func addTabBarItems(){
        var barItems:[Item] = []
        
        for subjectDoc in subjectDocs {
            let subjectName = subjectDoc.documentID
            barItems.append(Item.init(title: subjectName))
        }
        
        self.bar.items = barItems
    }
    
    func setupSubjects(){
        var recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingsTableVC") as! RecordingsTableViewController
        viewControllers.append(recordingVC)
        recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingsTableVC") as! RecordingsTableViewController
        viewControllers.append(recordingVC)
        recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingsTableVC") as! RecordingsTableViewController
        viewControllers.append(recordingVC)
        self.reloadPages()
    }
    
    // MARK: - PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    // MARK: - Actions

    @IBAction func pressedSettingsButton(_ sender: Any) {
        // TODO: Go to a settings page
        // Currenty: signs user out
        try? Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func pressedHighlightKeywordsButton(_ sender: Any) {
        let popup = KeywordsPopupView()
        popup.present(viewController: self)
    }
    
    @IBAction func pressedAddSubjectButton(_ sender:  Any) {
        let popup = AddSubjectPopupView()
        popup.present(viewController: self)
    }
    
    @IBAction func pressedNewRecordingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "newRecording", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newRecording" {
            let newRecordingViewCont = segue.destination
            // TODO:
        } else if segue.identifier == "viewRecording" {
            let viewRecordingViewCont = segue.destination
            
        }
    }
}
