//
//  SettingsViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/26/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    static var isSigningOut = false
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - SettingsViewController

    

    // MARK: - Actions

    @IBAction func pressedCloseNavButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            let subject: Subject = DataManager.sharedInstance.subjects[indexPath.row]
            
            // create the alert
            let alert = UIAlertController(title: "Delete \(subject.name)", message: "Are you sure you want to delete this subject?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { alert in
                DataManager.sharedInstance.deleteSubject(subject: subject) {
                    HomePageViewController.shouldReloadOnAppear = true
                    DataManager.sharedInstance.loadSubjectsAndRecordings {
                        tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)

        } else {
            // Pressed the sign out button
            
            // create the alert
            let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.destructive, handler: { alert in
                SettingsViewController.isSigningOut = true
                try? Auth.auth().signOut()
                FBSDKAccessToken.setCurrent(nil)
                self.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? DataManager.sharedInstance.subjects.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let subjectCell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as! SettingsSubjectTableViewCell
            
            subjectCell.subjectLabel.text = DataManager.sharedInstance.subjects[indexPath.row].name
            
            return subjectCell
        } else {
            let signOutCell = tableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath)
            
            return signOutCell
        }
        
    }
}
