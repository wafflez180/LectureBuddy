//
//  AddKeywordTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/12/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class AddKeywordTableViewCell: UITableViewCell {
    
    @IBOutlet var innerContentView: UIView!
    @IBOutlet var keywordTextField: UITextField!
    
    var delegate:TableViewProtocol?
    
    // MARK: - UITableViewCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - AddKeywordTableViewCell
    
    func setupUI(){
        self.keywordTextField.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.175, execute: {
            self.keywordTextField.becomeFirstResponder()
        })
    }
        
    // MARK: - Actions
    
    @IBAction func pressedAddButton(_ sender: Any) {
        self.delegate?.addKeyword(keyword: self.keywordTextField.text!)
    }
}
