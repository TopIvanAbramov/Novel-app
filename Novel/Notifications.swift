//
//  Notifications.swift
//  Novel
//
//  Created by Иван Абрамов on 21.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Notifications {
    
    func showAlert(title : String, message : String, buttonText : String, view: UIViewController) {
      let alert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
      view.present(alert, animated: true)
    }
    
    func scheduleNotification(withTitle title: String, andBody body: String, onDate date: Date, withIdentifier identifier: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        AppDelegate().notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
}

