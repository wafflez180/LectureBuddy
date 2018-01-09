//
//  TextViewExtension.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/9/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func scrollToBotom() {
        let range = NSMakeRange(text.characters.count - 1, 1);
        scrollRangeToVisible(range);
    }
}
