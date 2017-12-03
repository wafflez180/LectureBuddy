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

class HomeTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "subjectCellReuseID")
        setupTableViewPullToRefresh()
        setupLongPressGesture()
        refreshTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshTableView()
    }
    
    // MARK: - HomeTableViewController
    
    func setupLongPressGesture(){
        //Long Press
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedToDeleteSubject))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    func setupTableViewPullToRefresh(){
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = UIColor.white
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    @objc func refreshTableView(){
        DataManager.sharedInstance.getSubjectDocuments(completion: {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            })
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.subjectDocs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subjectDocs = DataManager.sharedInstance.subjectDocs
        let subjectName = subjectDocs[indexPath.row].documentID
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        
        if let subjectExpandedDict = isSubjectExpandedDict {
            if let isExpanded = subjectExpandedDict[subjectName] {
                if isExpanded {
                    return 255
                }
            }
        }
        
        return 75
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subjectDocs = DataManager.sharedInstance.subjectDocs
        let subjectName = subjectDocs[indexPath.row].documentID
        
        let subjectCell = tableView.dequeueReusableCell(withIdentifier: "subjectCellReuseID", for: indexPath) as! SubjectTableViewCell
        subjectCell.configureCell(subjectName: subjectName, parent: tableView)
        print("Displaying the \"\(subjectName)\"  subject tableViewCell")
        
        return subjectCell
    }
    
    // MARK: - Long Press Gesture Recognizer
    
    @objc func longPressedToDeleteSubject(longPressGesture:UILongPressGestureRecognizer){
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGesture.state == UIGestureRecognizerState.began) {
            print("Long press on row, at \(indexPath!.row)")
            let subjectCell = tableView.cellForRow(at: indexPath!) as! SubjectTableViewCell
            
            self.presentDeleteSubjectConfirmationAlert(subjectName: subjectCell.subjectName)
        }
    }
    
    func presentDeleteSubjectConfirmationAlert(subjectName:String){
        let alert = UIAlertController(title: "Delete \(subjectName)", message: """
            Are you sure you want to delete \(subjectName)?
            You can not undo this action.
            """, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { alertAction in
            DataManager.sharedInstance.deleteSubect(subjectName: subjectName, completionHandler: {
                self.tableView.reloadData()
            })
        }))
        self.present(alert, animated: true, completion: nil)
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
