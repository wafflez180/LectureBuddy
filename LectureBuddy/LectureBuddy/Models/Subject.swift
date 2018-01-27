//
//  Subject.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/21/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Subject: NSObject {
    
    var name: String
    var dateCreated: Date
    var documentID: String
    var recordings: [Recording]
    
    init(document: DocumentSnapshot) {
        let docData = document.data()!
        
        self.documentID = document.documentID
        self.name = docData["name"] as! String
        self.dateCreated = docData["dateCreated"] as! Date
        self.recordings = []
    }
}

