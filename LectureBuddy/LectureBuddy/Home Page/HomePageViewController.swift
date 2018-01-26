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
import NVActivityIndicatorView

class HomePageViewController: TabmanViewController, PageboyViewControllerDataSource {
    
    @IBOutlet var tabBarContainerView: UIView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    var viewControllers:[UIViewController] = []
    
    static var shouldReloadOnAppear = false
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        hideBottomiPhoneXBar()
        
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.dataSource = self
        
        configureTabBar()
        setTabBarItems()
        setSubjectPages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if HomePageViewController.shouldReloadOnAppear {
            reloadData()
            HomePageViewController.shouldReloadOnAppear = false
        }
        
        if SettingsViewController.isSigningOut {
            self.dismiss(animated: false, completion: nil)
            SettingsViewController.isSigningOut = false
        }
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
        let indexBeforeReload = self.currentIndex ?? 0
        activityIndicator.startAnimating()
        DataManager.sharedInstance.loadSubjectsAndRecordings {
            self.activityIndicator.stopAnimating()
            self.setTabBarItems()
            self.setSubjectPages()
            self.scrollToPage(PageboyViewController.Page.at(index: indexBeforeReload), animated: false)
        }
    }
    
    func setTabBarItems(){
        var barItems:[Item] = []
        
        for subject in DataManager.sharedInstance.subjects {
            let subjectName = subject.documentID
            barItems.append(Item.init(title: subjectName))
        }
        
        self.bar.items = barItems
    }
    
    func setSubjectPages(){
        viewControllers = []
        
        for index in 0..<DataManager.sharedInstance.subjects.count {
            let recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingsTableVC") as! RecordingsTableViewController
            recordingVC.recordings = DataManager.sharedInstance.subjects[index].recordings
            viewControllers.append(recordingVC)
        }
        
        self.reloadPages()
    }
    /*
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
    }*/
    
    // MARK: - PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        let recordingTableViewCont = viewControllers[index] as! RecordingsTableViewController
        
        recordingTableViewCont.recordings = DataManager.sharedInstance.subjects[index].recordings

        return viewControllers[index]
    }
    
    // TODO: - Add a default page! (design it first)
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil // TODO: - Save open the last page they were on (NSUserDefaults) PageboyViewController.Page.at(index: 0)
    }
    
    // MARK: - Actions
    
    @IBAction func pressedHighlightKeywordsButton(_ sender: Any) {
        let popup = KeywordsPopupView()
        popup.present(viewController: self)
    }
    
    @IBAction func pressedAddSubjectButton(_ sender:  Any) {
        let popup = AddSubjectPopupView()
        popup.present(viewController: self)
    }
    
    @IBAction func pressedNewRecordingButton(_ sender: Any) {
        var newRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recordingViewCont") as! RecordingViewController
        newRecordingVC.subject = DataManager.sharedInstance.subjects[self.currentIndex!]

        self.present(newRecordingVC, animated: true, completion: nil)
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
}
