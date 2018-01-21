//
//  Recording.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/21/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Recording: NSObject {
    
    var title: String
    var text: String
    var dateCreated: Date
    var documentID: String?
    
    init(document: DocumentSnapshot) {
        let docData = document.data()
        
        self.documentID = document.documentID
        self.title = docData["title"] as! String
        self.text = docData["text"] as! String
        self.dateCreated = docData["dateCreated"] as! Date
    }
    
    init(title: String, text: String){
        self.title = title
        self.text = text
        self.dateCreated = Date()
        self.documentID = nil
    }
}

