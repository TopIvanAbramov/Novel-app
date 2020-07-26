//
//  ChooseAuthorizationViewController.swift
//  ToDo
//
//  Created by Иван Абрамов on 23.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import Firebase

class ChooseAuthorizationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.layer.cornerRadius =  20
        
//        FirebaseAuth.Auth.auth().addStateDidChangeListener { (auth, user) in
//                   if user != nil {
//                       self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
//                   }
//        }
        
        stackView.isHidden = false
        logoImage.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUp" {
            stackView.isHidden = true
            logoImage.isHidden =  true
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .signUp
        } else if segue.identifier == "singIn" {
            stackView.isHidden = true
            logoImage.isHidden = true
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .singIn
        }
    }
    

}
