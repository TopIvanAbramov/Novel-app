//
//  User.swift
//  Novel
//
//  Created by Иван Абрамов on 12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import Firebase

struct AppUser {
    
    let uid: String
    let email: String
    let username: String
    let refCode: String
    let diamondCurrency: Int
    let ticketCurrency: Int
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
        self.username = user.displayName ?? ""
        self.refCode = user.uid
        self.diamondCurrency = 0
        self.ticketCurrency = 0
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String
        email = snapshotValue["email"] as! String
        username = snapshotValue["username"] as! String
        refCode = snapshotValue["refCode"] as! String
        diamondCurrency = snapshotValue["diamondCurrency"] as! Int
        ticketCurrency = snapshotValue["ticketCurrency"] as! Int
    }
}
