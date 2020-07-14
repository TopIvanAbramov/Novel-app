//
//  HistoryCategories.swift
//  Novel
//
//  Created by Иван Абрамов on 12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import Firebase

struct Category {
    var name: String
    var color: String
    let ref: DatabaseReference?
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        color = snapshotValue["color"] as! String
        ref = snapshot.ref
    }
}
