//
//  RecordingsTableViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/22/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import ViewAnimator

class RecordingsTableViewController: UITableViewController {
    
    var recordings:[Recording] = []
    
    static var hasPlayedShowAnimation = false
    
    // MARK: - UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = .init(top: 100, left: 0, bottom: 0, right: 0)
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Appearing with \(recordings.count) recordings")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if RecordingsTableViewController.hasPlayedShowAnimation == false {
            
            let translationAnimation = AnimationType.from(direction: .bottom, offset: 30.0)

            tableView.animateViews(animations: [translationAnimation],
                                   reversed: false,
                                   initialAlpha: 0.5,
                                   finalAlpha: 1.0,
                                   delay: 0.0,
                                   duration: 0.5,
                                   animationInterval: 0.1,
                                   completion: nil)
            
            RecordingsTableViewController.hasPlayedShowAnimation = true
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.recordings.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyStateHeader")
        } else {
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.recordings.count == 0 ? 250 : 20
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recordingCell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath) as! RecordingTableViewCell
        
        recordingCell.setup(recording: recordings[indexPath.row])

        return recordingCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recordingCell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
        recordingCell.containerView.backgroundColor = UIColor.init(hex: "E8E8E8")
        
        var recordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recordingViewCont") as! RecordingViewController
        
        recordingVC.setupToView(recording: recordings[indexPath.row])
        
        self.present(recordingVC, animated: true, completion: {
            recordingCell.containerView.backgroundColor = .white
        })
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
