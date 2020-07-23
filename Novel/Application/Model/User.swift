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
    let didAddreferalBonus: Bool
    let heartCurrency: Int
    let energyCurrency: Int
    let bonusTime: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
        self.username = user.displayName ?? ""
        self.refCode = user.uid
        self.heartCurrency = 0
        self.energyCurrency = 0
        self.didAddreferalBonus = true
        self.bonusTime = ""
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String
        email = snapshotValue["email"] as! String
        username = snapshotValue["username"] as! String
        refCode = snapshotValue["refCode"] as! String
        heartCurrency = snapshotValue["heartCurrency"] as! Int
        energyCurrency = snapshotValue["energyCurrency"] as! Int
        didAddreferalBonus = snapshotValue["didAddreferalBonus"] as! Bool
        bonusTime = snapshotValue["bonusTime"] as! String
    }
}
