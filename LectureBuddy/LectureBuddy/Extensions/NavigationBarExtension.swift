//
//  NavigationBarExtension.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/22/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
