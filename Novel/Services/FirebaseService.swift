//
//  FirebaseService.swift
//  Novel
//
//  Created by Иван Абрамов on 04.08.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService {
    
    let database: Database = Database.database()
    
    func getCurrentUser() ->  AppUser? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        let user = AppUser(user: currentUser)
        
        return user
    }
    
    func updateHeartCurrency(withValue value: Int, forUserWithUID uid: String) {
        let userRef = database.reference(withPath: "users/\(uid)")
        userRef.child("heartCurrency").setValue(value)
    }
    
    func updateEnergyCurrency(withValue value: Int, forUserWithUID uid: String) {
        let userRef = database.reference(withPath: "users/\(uid)")
        userRef.child("energyCurrency").setValue(value)
    }
    
    func observeCategories(withCompletion completion: @escaping (Array<Category>) -> Void ) {
        DispatchQueue.global(qos: .background).async {
            self.database.reference(withPath: "categories").observe(.value, with: { (snapshot) in
               var _categories = Array<Category>()
               var recomendations = Array<Category>()
               
               for item in snapshot.children {
                   let category = Category(snapshot: item as! DataSnapshot)
                   
                   if category.name == "Рекомендации" {
                       recomendations.append(category)
                   } else {
                         _categories.append(category)
                   }
               }
                
                var categories = Array<Category>()
                categories = recomendations
                categories += _categories
                
                completion(categories)
            })
        }
    }
    
    func updateBonusTime(forUserWithUID uid: String, withValue value: String) {
        let userRef = Database.database().reference(withPath: "users/\(uid)")
        userRef.child("bonusTime").setValue(value)
    }
    
    func updateHeartBonusTime(forUserWithUID uid: String, withValue value: String) {
        let userRef = Database.database().reference(withPath: "users/\(uid)")
        userRef.child("heartBonusTime").setValue(value)
    }
    
    
    func updateStyle(forUserWithUID uid: String, styleWithModel model: [StyleState: String], completion: @escaping ([StyleState: String]) -> Void ) {
        let userRef = Database.database().reference(withPath: "users/\(uid)")
        userRef.child("characterStyle").setValue(["гендер": model[.gender], "раса": model[.race], "волосы": model[.hair]])
        
        completion(model)
    }
    
    func updateHeartState(forUserWithUID uid: String, withValue value: String) {
        let userRef = Database.database().reference(withPath: "users/\(uid)")
        userRef.child("heartState").setValue(value)
    }
    
    func updateDidAddreferalBonus(forUserWithUID uid: String, withValue value: Bool) {
        let userRef = Database.database().reference(withPath: "users/\(uid)")
        userRef.child("didAddreferalBonus").setValue(value)
    }
    
}
