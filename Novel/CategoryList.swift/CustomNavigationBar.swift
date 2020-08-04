//
//  CustomNavigationBar.swift
//  Novel
//
//  Created by Иван Абрамов on 20.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

protocol NavigationBarDelegate: class {
    func leftButtonTapped()
    func rightButtonTapped()
    func changeStyleTapped()
}

@IBDesignable class CustomNavigationBar: UIView {

    weak var delegate: NavigationBarDelegate?
    
    @IBOutlet weak var leftButtonView: UIButton!
    @IBOutlet weak var rightButtonView: UIButton!
    @IBOutlet weak var styleButtonView: UIButton!
    @IBOutlet weak var leffButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heartCurrency: UILabel!
    @IBOutlet weak var energyCurrency: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
   override init(frame: CGRect) {
       super.init(frame: frame)
       commonInit()
   }
    
   
   private func commonInit() {
    if self.subviews.count == 0 {
            Bundle.main.loadNibNamed("CustomNavigationBar", owner: self, options: nil)
            addSubview(contentView)
        
            contentView.frame = self.bounds
            self.contentView.translatesAutoresizingMaskIntoConstraints = true
    
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
            leffButton.tintColor = .yellow
            rightButton.tintColor = .yellow
    }
   
   }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
           delegate?.leftButtonTapped()
    }
       
   @IBAction func rightButtonTapped(_ sender: Any) {
       delegate?.rightButtonTapped()
   }
    
    @IBAction func changeStyleTapped(_ sender: Any) {
        delegate?.changeStyleTapped()
    }
     
    func updateHeartCurrency(withValue value: Int) {
        if let currentCurrency = Int((heartCurrency.text)!) {
            heartCurrency.text = String(currentCurrency) + String(value)
        }
    }
    
    func updateEnergyCurrency(withValue value: Int) {
         if let currentCurrency = Int((energyCurrency.text)!) {
            energyCurrency.text = String(currentCurrency) + String(value)
        }
    }
    
    func setHeartCurrency(withValue value: Int) {
        heartCurrency.text = String(value)
    }
    
    func setEnergyCurrency(withValue value: Int) {
        energyCurrency.text = String(value)
    }
}
