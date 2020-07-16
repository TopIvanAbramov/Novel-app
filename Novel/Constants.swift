//
//  Constants.swift
//  Novel
//
//  Created by Иван Абрамов on 16.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import Firebase

class Constants {
    
    var ref = Database.database()
    
    struct Storyboard {
        var signUp = "signUp"
        var signIn = "signIn"
    }
}

func getBonuses(completion: @escaping (Bonuses) -> Void) -> Bonuses {
    var bonuse = Bonuses()
    
    Constants().ref.reference(withPath: "bonuses").observeSingleEvent(of: .value, with: { (snapshot) in
        let newbonuse = Bonuses(snapshot: snapshot)
        
         print("\n\n Function:", newbonuse.referalBonuse,  newbonuse.dailyBonuse, newbonuse.firstRegistrationBonuse, "\n\n")
        
         bonuse = newbonuse
        
        print("\n\n Bonuse function:", newbonuse.referalBonuse,  newbonuse.dailyBonuse, newbonuse.firstRegistrationBonuse, "\n\n")
        
        completion(bonuse)
    })

    
    return bonuse
}
