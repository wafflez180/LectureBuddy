//
//  KeywordTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/12/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class KeywordTableViewCell: UITableViewCell {

    @IBOutlet var keywordLabel: UILabel!
    
    var delegate:TableViewProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Actions
    
    @IBAction func pressedDeleteButton(_ sender: Any) {
        delegate?.deleteKeyword(cell: self)
    }
}
