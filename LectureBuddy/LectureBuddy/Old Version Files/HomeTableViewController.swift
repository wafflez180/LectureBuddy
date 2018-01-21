//
//  HomeTableViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class HomeTableViewController: UITableViewController {
    
    var didLeaveViewCont = false
    var isRefreshing = false
    
    // Extension HomeTableViewController: UIViewControllerTransitioningDelegate variables
    static var selectedRecordingCell:NewRecordingCollectionViewCell?
    var dimissTransitionFrame:CGRect?
    var interactionController:UIPercentDrivenInteractiveTransition?
    
    // MARK: - UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "subjectCellReuseID")
        tableView.register(UINib(nibName: "SubjectHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "subjectHeaderReuseID")

        setupTableViewPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if didLeaveViewCont {
            refreshTableView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        didLeaveViewCont = true
    }
    
    
    // MARK: - HomeTableViewController
    
    func setupTableViewPullToRefresh(){
        self.extendedLayoutIncludesOpaqueBars = true
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = UIColor.white
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    func isSubjectExpanded(subjectName:String) -> Bool {
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if let subjectExpandedDict = isSubjectExpandedDict {
            if let isExpanded = subjectExpandedDict[subjectName] {
                if isExpanded {
                    return true
                }
            }
        }
        return false
    }
    
    @objc func refreshTableView(){
        isRefreshing = true
        DataManager.sharedInstance.getSubjectDocuments(completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.tableView.refreshControl?.endRefreshing()
                UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
                    self.tableView.reloadData()
                }) { _ in
                    self.isRefreshing = false
                }
            })
        })
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataManager.sharedInstance.subjects.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subjectDocs = DataManager.sharedInstance.subjects
        let subjectName = subjectDocs[indexPath.section].documentID
        
        if isSubjectExpanded(subjectName: subjectName) {
            return 180
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var subjectHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "subjectHeaderReuseID") as! SubjectHeaderView
        let subjects = DataManager.sharedInstance.subjects
        let subjectName = subjects[section].documentID
        
        subjectHeaderView.configure(subjectName: subjectName, sectionNum: section, parentTableView: tableView, parentVC: self)
        
        return subjectHeaderView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subjects = DataManager.sharedInstance.subjects
        let subjectName = subjects[indexPath.section].documentID
        let subjectCell = tableView.dequeueReusableCell(withIdentifier: "subjectCellReuseID", for: indexPath) as! SubjectTableViewCell
        
        subjectCell.configureCell(subjectName: subjectName, indexPath: indexPath, isExpanded: isSubjectExpanded(subjectName: subjectName), parentVC: self, isRefreshingTable:isRefreshing)
        print("AH")
        //print("Displaying the \"\(subjectName)\"  subject tableViewCell")
        return subjectCell
    }
    
    // MARK: - Actions
    
    @IBAction func pressedSignOutButton(_ sender: Any) {
        try? Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func pressedKeywordsButton(_ sender: Any) {
        let popup = KeywordsPopupView()
        popup.present(viewController: self)
    }
    
    @IBAction func pressedAddSubject(_ sender: Any) {
        let popup = AddSubjectPopupView()
        popup.present(viewController: self)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension HomeTableViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = TransitionAnimationController(presenting: true)
        
        transition.originFrame = HomeTableViewController.selectedRecordingCell!.superview!.convert(HomeTableViewController.selectedRecordingCell!.frame, to: nil)
        
        
        let heightToWidthDeviceRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        var newFrame = transition.originFrame
        // Set the width so the ratio is the same as the finished transition VC ratio
        newFrame.size.width = heightToWidthDeviceRatio * newFrame.size.height // Collection cell's width
        print(newFrame.size.width)
        // For less jittery UI, start smaller than the newRecordingCell's frame
        newFrame.size.height -= 10
        newFrame.origin.y += 5
        transition.originFrame = newFrame
        
        dimissTransitionFrame = newFrame
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = TransitionAnimationController(presenting: false)
        
        // Make the frame at the end to be smaller than the original frame of the cell,
        // so when the view disappears it will be unnoticeable
        var newFrame = dimissTransitionFrame!
        newFrame.size.width -= 20
        newFrame.origin.x += 10
        newFrame.size.height -= 20
        newFrame.origin.y += 10
        
        transition.originFrame = newFrame
        
        return transition
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    //    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    //        guard let animator = animator as? TransitionAnimationController,
    //            let interactionController = animator.interactionController,
    //            interactionController.interactionInProgress
    //            else {
    //                return nil
    //        }
    //        return interactionController
    //    }
}
