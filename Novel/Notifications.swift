//
//  Notifications.swift
//  Novel
//
//  Created by Иван Абрамов on 21.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import UIKit

class Notifications {
    
    func showAlert(title : String, message : String, buttonText : String, view: UIViewController) {
      let alert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
      view.present(alert, animated: true)
    }
    
}

