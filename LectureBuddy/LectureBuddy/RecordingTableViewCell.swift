//
//  RecordingTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/22/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
