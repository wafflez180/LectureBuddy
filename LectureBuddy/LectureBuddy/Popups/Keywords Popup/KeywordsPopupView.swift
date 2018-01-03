//
//  AddKeywordPopupView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/12/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

protocol TableViewProtocol: class {
    func deleteKeyword(cell:UITableViewCell)
    func addKeyword(keyword:String)
}

class KeywordsPopupView: PopupContentView, PopupViewProtocol, TableViewProtocol, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var addingKeyword = false
    var addKeywordCell:AddKeywordTableViewCell?
    
    // MARK: - PopupViewProtocol
    
    func popupDidAppear() {
        
    }
    
    func getTitle() -> String {
        return "Highlighting Keywords"
    }
    
    func getButtonTitle() -> String {
        return "Add Keyword"
    }
    
    func pressedMainButton(success: @escaping () -> Void, error: @escaping (UIAlertController?)  -> Void, doNothing: @escaping () -> Void) {
        if addingKeyword == false {
            addingKeyword = true
            tableView.reloadData()
            // Scroll to bottom
            let addKeywordIndexPath = IndexPath.init(row: 0, section: 1)
            tableView.scrollToRow(at: addKeywordIndexPath, at: .bottom, animated: true)
        }
        doNothing()
    }
    
    // MARK: - AddKeywordPopupView
    
    override func awakeFromNib() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "KeywordTableViewCell", bundle: nil), forCellReuseIdentifier: "keywordReuseID")
        tableView.register(UINib(nibName: "AddKeywordTableViewCell", bundle: nil), forCellReuseIdentifier: "addKeywordReuseID")
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if addingKeyword {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return DataManager.sharedInstance.highlightedKeywords.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let keywordCell = tableView.dequeueReusableCell(withIdentifier: "keywordReuseID", for: indexPath) as! KeywordTableViewCell
            keywordCell.keywordLabel.text = DataManager.sharedInstance.highlightedKeywords[indexPath.row]
            keywordCell.delegate = self
            return keywordCell
        }else{
            addKeywordCell = tableView.dequeueReusableCell(withIdentifier: "addKeywordReuseID", for: indexPath) as! AddKeywordTableViewCell
            addKeywordCell!.delegate = self
            addKeywordCell!.setupUI()
            return addKeywordCell!
        }
    }
    
    // MARK: - TableViewProtocol
    
    func deleteKeyword(cell:UITableViewCell){
        print("Pressed delete")
        let cellIndexPath = tableView.indexPath(for: cell)!
        
        tableView.beginUpdates()
        DataManager.sharedInstance.deleteKeyword(index: cellIndexPath.row)
        tableView.deleteRows(at: [cellIndexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func addKeyword(keyword:String){
        print("Pressed add")
        addingKeyword = false
        DataManager.sharedInstance.addKeyword(keyword: keyword)
        tableView.reloadData()
        // Flash the cell purple
        let lastRowIndex = (tableView.numberOfRows(inSection: 0)-1)
        let newlyAddedRow = tableView.cellForRow(at: IndexPath.init(row: lastRowIndex, section: 0)) as! KeywordTableViewCell
        newlyAddedRow.flashBackgroundColor()
    }
}
