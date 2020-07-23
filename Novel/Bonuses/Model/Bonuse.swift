//
//  Bonuse.swift
//  Novel
//
//  Created by Иван Абрамов on 23.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Firebase
import Foundation

struct Bonuse {
    
    let referalBonuse: Int
    let dailyBonuse: Int
    let firstRegistrationBonuse: Int
    
//    init(referalBonuse: Int, dailyBonuse: Int, firstRegistrationBonuse: Int) {
//        self.referalBonuse = referalBonuse
//        self.dailyBonuse = dailyBonuse
//        self.firstRegistrationBonuse = firstRegistrationBonuse
//    }
    
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
