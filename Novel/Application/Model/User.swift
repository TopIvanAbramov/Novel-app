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
//    let refCode: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
//        self.refCode = user.refCode
    }
}
