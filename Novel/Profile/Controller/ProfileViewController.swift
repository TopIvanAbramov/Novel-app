//
//  ProfileViewController.swift
//  Novel
//
//  Created by Иван Абрамов on 12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UITableViewController {

    @IBOutlet weak var promocodeLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    
    var ref: DatabaseReference!
    var user: AppUser!
    var categories = Array<Category>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addReferalCodeCopyGesture()
    }
    
    func setupprofile() {
        promocodeLabel.text = user.refCode
        username.text = user.username
        
        promocodeLabel.sizeToFit()
    }
    
    //    MARK: - ViewLifeCycle
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = "Профиль"
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard currentUser != nil else {
            print("No current user")
            logOutTapped(sender: (Any).self)
            
            return
        }
        
        
//        logOutTapped(sender: (Any).self)
        
        user = AppUser(user: currentUser)
        ref = Database.database().reference(withPath: "users/\(user.uid)")
        
        print(user.uid)
        
        
        self.ref.observe(.value, with: {[weak self] (snapshot) in
            self?.user = AppUser(snapshot: snapshot)
            self?.setupprofile()
        })
    }
    
    func addReferalCodeCopyGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        promocodeLabel.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress() {
        print("Copy promocode")
        UIPasteboard.general.string = promocodeLabel.text
    }
    

    @IBAction func logOutTapped(sender: Any) {
        
        do {
            try Firebase.Auth.auth().signOut()
            performSegue(withIdentifier: "returnToAuthorization", sender: self)
        } catch {
        }
    }
    
    
}
