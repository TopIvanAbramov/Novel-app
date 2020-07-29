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
    }
    
    func setupprofile() {
        promocodeLabel.text = user.refCode
        username.text = user.username
        
        promocodeLabel.sizeToFit()
    }
    
    @IBAction func copyButtonTapped(sender: UIButton) {
        let link = "https://www.apple.com/ru/itunes/"
        guard let promoCode = promocodeLabel.text else { return }
        
        showShareView(withText: "Привет! Скачивай приложение по этой ссылке (\(link)), и вводи промокод \(promoCode) получай 30 энергий бесплатно!")
//        UIPasteboard.general.string = promocodeLabel.text
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
    
    func showShareView(withText text: String) {
        let textToShare = text

        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [textToShare], applicationActivities: nil)

        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.view

        // This line remove the arrow of the popover to show in iPad
//        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Anything you want to exclude
//        activityViewController.excludedActivityTypes = [
//            UIActivityTypePostToWeibo,
//            UIActivityTypePrint,
//            UIActivityTypeAssignToContact,
//            UIActivityTypeSaveToCameraRoll,
//            UIActivityTypeAddToReadingList,
//        ]

        self.present(activityViewController, animated: true, completion: nil)

    }
    

    @IBAction func logOutTapped(sender: Any) {
        
        do {
            try Firebase.Auth.auth().signOut()
            performSegue(withIdentifier: "returnToAuthorization", sender: self)
            AppDelegate().notificationCenter.removeAllPendingNotificationRequests()
            AppDelegate().notificationCenter.removeAllDeliveredNotifications()
        } catch {
        }
    }
    
    
}
