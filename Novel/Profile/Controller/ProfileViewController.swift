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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addReferalCodeCopyGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = "Профиль"
    }
    
    func addReferalCodeCopyGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        promocodeLabel.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress() {
        print("Copy promocode")
        UIPasteboard.general.string = promocodeLabel.text
    }
    

    @IBAction func logOutTapped(sender: UIButton) {
        
        do {
            try Firebase.Auth.auth().signOut()
            performSegue(withIdentifier: "returnToAuthorization", sender: self)
        } catch {
        }
    }
    
    
}
