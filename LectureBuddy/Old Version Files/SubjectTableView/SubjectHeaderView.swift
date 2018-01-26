//
//  SubjectHeaderView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/15/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectHeaderView: UITableViewHeaderFooterView, UIGestureRecognizerDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headerButton: UIButton!
    
    var parentViewCont:UIViewController!
    var parentTableView:UITableView!
    var subjectName:String!
    var sectionNum:Int!
    let highlightedColor:UIColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    
    // MARK: - UITableViewHeaderFooterView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setupLongPressGesture()
    }
    
    // MARK: - SubjectHeaderView
    /*
    func setupLongPressGesture(){
        //Long Press
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(presentDeleteSubjectConfirmationAlert))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }*/

    func configure(subjectName: String, sectionNum:Int, parentTableView: UITableView, parentVC: UIViewController){
        self.subjectName = subjectName
        self.titleLabel.text = subjectName
        self.sectionNum = sectionNum
        self.parentTableView = parentTableView
        self.parentViewCont = parentVC
        
        setSubjectSelectionFromCache(subjectName: subjectName)
    }
    
    func setSubjectSelectionFromCache(subjectName:String){
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if let isSubjectSelected = isSubjectExpandedDict?[subjectName] {
            headerButton.isSelected = isSubjectSelected
        }
    }
    
    func cacheSubjectSelection(selected:Bool){
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if isSubjectExpandedDict == nil {
            let dict:[String:Bool] = [subjectName: headerButton.isSelected]
            UserDefaults.standard.set(dict, forKey: "isSubjectSelectedDict")
        }else{
            isSubjectExpandedDict![subjectName] = headerButton.isSelected
            UserDefaults.standard.set(isSubjectExpandedDict!, forKey: "isSubjectSelectedDict")
        }
        print(isSubjectExpandedDict)
    }
    
    // MARK: - Long Press Gesture Recognizer
    /*
    @objc func presentDeleteSubjectConfirmationAlert(){
        let alert = UIAlertController(title: "Delete \(subjectName!)", message: """
            Are you sure you want to delete \(subjectName!)?
            You can not undo this action.
            """, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { alertAction in
            DataManager.sharedInstance.deleteSubject(subjectName: self.subjectName, completionHandler: {
                self.parentTableView.reloadData()
            })
        }))
        self.parentViewCont.present(alert, animated: true, completion: nil)
    }*/
    
    // MARK: - Actions
    
    @IBAction func didPressSelect(_ sender: Any) {
        headerButton.isSelected = !headerButton.isSelected
        cacheSubjectSelection(selected: headerButton.isSelected)
        
        let indexToReload = IndexPath.init(row: 0, section: self.sectionNum)
        let cellToReload = self.parentTableView.cellForRow(at: indexToReload) as! SubjectTableViewCell
        
        if headerButton.isSelected {
            cellToReload.animateShow()
        }else{
            cellToReload.animateHide()
        }
        
        self.contentView.backgroundColor = self.highlightedColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.contentView.backgroundColor = UIColor.white
        }
    }
}
