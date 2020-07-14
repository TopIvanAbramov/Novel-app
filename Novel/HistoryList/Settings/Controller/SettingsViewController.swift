//
//  SettingsViewController.swift
//  Novel
//
//  Created by Иван Абрамов on 13.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = "Настройки"
    }

}
