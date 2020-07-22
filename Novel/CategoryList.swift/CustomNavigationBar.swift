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
}

@IBDesignable class CustomNavigationBar: UIView {

    weak var delegate: NavigationBarDelegate?
    
    @IBOutlet weak var leftButtonView: UIButton!
    @IBOutlet weak var rightButtonView: UIButton!
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
             print("\n\nCommon init\n\n")
            
                Bundle.main.loadNibNamed("CustomNavigationBar", owner: self, options: nil)
                addSubview(contentView)
        //
                contentView.frame = self.bounds
                self.contentView.translatesAutoresizingMaskIntoConstraints = true
        
                contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//                leffButton.setTitleColor(.yellow, for: .normal)
//                leffButton.tintColor = #colorLiteral(red: 0.9686413407, green: 0.9036722779, blue: 0.02564223483, alpha: 1)
//        
//                rightButton.tintColor = #colorLiteral(red: 1, green: 0.9127054811, blue: 0, alpha: 1)
        
////              Add shadows
//                buttonsBackground.layer.shadowColor = UIColor.gray.cgColor
//                buttonsBackground.layer.shadowOpacity = 0.3
//                buttonsBackground.layer.shadowOffset = CGSize(width: 0, height: 5)
//                buttonsBackground.layer.shadowRadius = 3
    }
   
   }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
           delegate?.leftButtonTapped()
    }
       
   @IBAction func rightButtonTapped(_ sender: Any) {
       delegate?.rightButtonTapped()
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
