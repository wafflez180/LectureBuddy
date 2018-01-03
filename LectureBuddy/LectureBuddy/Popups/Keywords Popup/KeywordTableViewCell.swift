//
//  KeywordTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/12/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class KeywordTableViewCell: UITableViewCell {

    @IBOutlet var innerContentView: UIView!
    @IBOutlet var keywordLabel: UILabel!
    
    var delegate:TableViewProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - KeywordTableViewCell

    func flashBackgroundColor(){
        let oldColor = self.innerContentView.backgroundColor
        // Fade to tintColor (grey)
        UIView.animate(withDuration: 0.15, delay: 0.0, options:[.curveEaseOut, .transitionCrossDissolve], animations: {
            self.innerContentView.backgroundColor = self.innerContentView.tintColor
        }) { completed in
            // Fade back to original background color (clear)
            UIView.animate(withDuration: 0.15, delay: 0.0, options:[.curveEaseIn, .transitionCrossDissolve], animations: {
                self.innerContentView.backgroundColor = oldColor
            })
        }
    }

    // MARK: - Actions
    
    @IBAction func pressedDeleteButton(_ sender: Any) {
        delegate?.deleteKeyword(cell: self)
    }
}
