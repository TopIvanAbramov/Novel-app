//
//  Bonuses.swift
//  Novel
//
//  Created by Иван Абрамов on 16.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Firebase

struct Bonuses {
    
    let referalBonuse: Int
    let dailyBonuse: Int
    let firstRegistrationBonuse: Int
    
    init(referalBonuse: Int, dailyBonuse: Int, firstRegistrationBonuse: Int) {
        self.referalBonuse = referalBonuse
        self.dailyBonuse = dailyBonuse
        self.firstRegistrationBonuse = firstRegistrationBonuse
    }
    
    init() {
        self.referalBonuse = 0
        self.dailyBonuse = 0
        self.firstRegistrationBonuse = 0
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        referalBonuse = snapshotValue["referalBonuse"] as! Int
        dailyBonuse = snapshotValue["dailyBonuse"] as! Int
        firstRegistrationBonuse = snapshotValue["firstRegistrationBonuse"] as! Int
    }
}
