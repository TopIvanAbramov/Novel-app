//
//  History.swift
//  Novel
//
//  Created by Иван Абрамов on 13.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import Firebase

struct History {
    var name: String
    var description: String
//    var picture:
    var refToFirstStory: DatabaseReference?
    let ref: DatabaseReference?
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
        self.refToFirstStory = nil
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        description = snapshotValue["description"] as! String
        refToFirstStory = snapshotValue["refToFirstStory"] as? DatabaseReference
        ref = snapshot.ref
    }
}
