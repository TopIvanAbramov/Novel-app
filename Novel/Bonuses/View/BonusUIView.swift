//
//  BonusUIView.swift
//  Novel
//
//  Created by Иван Абрамов on 22.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

protocol BonusUIViewDelegate: class {
    func bonusButtonTapped()
}

@IBDesignable
class BonusUIView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var getBonusButton: RoundButton!
    weak var delegate: BonusUIViewDelegate?
    
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
            Bundle.main.loadNibNamed("BonusUIView", owner: self, options: nil)
            addSubview(contentView)
            
            contentView.frame = self.bounds
            self.contentView.translatesAutoresizingMaskIntoConstraints = true
            
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            contentView.layer.cornerRadius = 30
            contentView.clipsToBounds = true
            
            titleLabel.textColor = .black
            subtitleLabel.textColor = .gray
        }
    }
    
    @IBAction func getBonusTapped(_ sender: Any) {
        delegate?.bonusButtonTapped()
    }
    
    func setTitle(withText text: String) {
        titleLabel.text = text
    }
    
    func setSubtitle(withText text: String) {
        subtitleLabel.text = text
    }
}
