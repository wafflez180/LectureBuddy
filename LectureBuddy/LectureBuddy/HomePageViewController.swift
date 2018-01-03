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
    
    @IBOutlet var tabBarContainerView: UIView!
    
    var viewControllers:[UIViewController] = []
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        hideBottomiPhoneXBar()
        
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.dataSource = self
        
        configureTabBar()
        reloadData()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - HomePageViewController
    
    func hideBottomiPhoneXBar(){
        // This is janky but if you remove this line of code there'll be a bottom bar cutting off the pageContentVC's content
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                self.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: -35, right: 0)
            default:
                print("unknown")
            }
        }
    }
    
    func configureTabBar(){
        self.embedBar(in: self.tabBarContainerView)
        
        // Appearance property list: https://github.com/uias/Tabman/blob/master/Docs/APPEARANCE.md
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.style.background = TabmanBar.BackgroundView.Style.solid(color: .clear)
            //appearance.layout.itemDistribution = TabmanBar.Appearance.Layout.ItemDistribution.centered
            
            appearance.text.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            
            appearance.indicator.color = ColorManager.darkSkyBlue
            
            appearance.state.color = ColorManager.lightGrey
            appearance.state.selectedColor = .white
        })
    }
    
    func reloadData(){
        setTabBarItems()
        setSubjectPages()
    }
    
    func setTabBarItems(){
        var barItems:[Item] = []
        
        for subjectDoc in DataManager.sharedInstance.subjectDocs {
            //print(subjectDoc.documentID)
            let subjectName = subjectDoc.documentID
            barItems.append(Item.init(title: subjectName))
        }
        
        self.bar.items = barItems
    }
    
    func setSubjectPages(){
        viewControllers = []
        
        for _ in 0..<DataManager.sharedInstance.subjectDocs.count {
            let recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingsTableVC") as! RecordingsTableViewController
            viewControllers.append(recordingVC)
        }
        
        self.reloadPages()
    }
    
    func deleteSubject(){
        let subjectName = self.bar.items![self.currentIndex!].title!
        let alert = UIAlertController(title: "Delete \(subjectName)", message: """
            Are you sure you want to delete \(subjectName)?
            You can not undo this action.
            """, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { alertAction in
            DataManager.sharedInstance.deleteSubect(subjectName: subjectName, completionHandler: {
                self.reloadData()
            })
        }))
        self.present(alert, animated: true, completion: nil)
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

    }
    
    
    // TODO: - Put this functionality in the settings view controller
    /*
    @IBAction func pressedMoreOptionsButton(_ sender: Any) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let deleteSubjectAction: UIAlertAction = UIAlertAction(title: "Delete Subject", style: .destructive) { action -> Void in
            self.deleteSubject()
            print("Delete Subject Action pressed")
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        // add actions
        actionSheetController.addAction(deleteSubjectAction)
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }*/
    
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
