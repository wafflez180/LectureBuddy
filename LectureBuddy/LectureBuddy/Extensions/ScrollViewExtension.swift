//
//  TextViewExtension.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/9/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollToBottom(animated:Bool) {
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}
