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

    var subjectDocs:[DocumentSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedInstance.getSubjectDocuments { subjectDocuments in
            self.subjectDocs = subjectDocuments
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DataManager.sharedInstance.getSubjectDocuments { subjectDocuments in
            self.subjectDocs = subjectDocuments
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subjectDocs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subjectCell = tableView.dequeueReusableCell(withIdentifier: "subjectCellIdentifier", for: indexPath) as! SubjectTableViewCell
        subjectCell.headerButton.setTitle(subjectDocs[indexPath.row].documentID, for: .normal)

        return subjectCell
    }
 
    // MARK: - Actions

    @IBAction func pressedSignOutButton(_ sender: Any) {
        try? Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func pressedAddSubject(_ sender: Any) {
        let popup = AddSubjectPopupView.instanceFromNib()
        popup.presentPopup(title: "Add New Subject", buttonTitle: "Add")
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
