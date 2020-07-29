//
//  HeartBonusView.swift
//  Novel
//
//  Created by Иван Абрамов on 26.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

enum HeartBonusState {
    case zero
    case one
    case two
    case three
    
    var description : String {
        switch self {
            case .zero: return "zero"
            case .one: return "one"
            case .two: return "two"
            case .three: return "three"
        }
    }
    
    var nextState : HeartBonusState {
        switch self {
        case .one:
            return .two
        case .two:
            return .three
        case .three:
            return .zero
        case .zero:
            return .one
        }
    }
}

enum ButtosStates {
    case Received
    case Receive
    case Inaccessible
}

protocol HeartBonusViewDelegate: class {
    func getBonusTapped()
    func closeButtonTapped()
}

class HeartBonusView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bonusBackgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var sectionBackground: [UIView]!
    @IBOutlet var heartViews: [UIImageView]!
    @IBOutlet var buttonViews: [RoundButton]!
    weak var delegate: HeartBonusViewDelegate?
    
    var state: HeartBonusState {
        didSet {
            updateUI()
        }
    }
    
    let stateViewDescription = [
        HeartBonusState.zero : [0: ButtosStates.Received, 1: ButtosStates.Received, 2: ButtosStates.Received],
        HeartBonusState.one : [0: ButtosStates.Receive, 1: ButtosStates.Inaccessible, 2: ButtosStates.Inaccessible],
        HeartBonusState.two : [0: ButtosStates.Received, 1: ButtosStates.Receive, 2: ButtosStates.Inaccessible],
        HeartBonusState.three : [0: ButtosStates.Received, 1: ButtosStates.Received, 2: ButtosStates.Receive]
    ]
    
    required init?(coder: NSCoder) {
         self.state = .zero
         super.init(coder: coder)
         commonInit()
     }
     
    override init(frame: CGRect) {
        self.state = .zero
        super.init(frame: frame)
        self.state = .zero
        commonInit()
    }
     
    
    private func commonInit() {
         if self.subviews.count == 0 {
             Bundle.main.loadNibNamed("HeartBonusView", owner: self, options: nil)
             addSubview(contentView)
             
             contentView.frame = self.bounds
             self.contentView.translatesAutoresizingMaskIntoConstraints = true
             
             contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
             
            bonusBackgroundView.layer.cornerRadius = 30
            bonusBackgroundView.clipsToBounds = true
            
            for view in sectionBackground {
                view.layer.cornerRadius = 15
            }
         }
     }
    
    
    @IBAction func getBonusTapped(_ sender: UIButton) {
        delegate?.getBonusTapped()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeButtonTapped()
    }
    
    
    func updateUI() {
        let currentState = stateViewDescription[state]
        
        for button in buttonViews {
            if let buttonState = currentState?[button.tag] {
                setup(button: button, forState: buttonState)
            }
        }
        
        for imageView in heartViews {
            if let imageViewState = currentState?[imageView.tag] {
                setup(imageView: imageView, forState: imageViewState)
            }
        }
    }
    
    func setup(button: UIButton, forState state: ButtosStates) {
        switch state {
        case .Received:
            button.setTitle("Получено", for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            button.isUserInteractionEnabled = false
            break
        case .Receive:
            button.setTitle("Получить", for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            button.isUserInteractionEnabled = true
        case .Inaccessible:
            button.setTitle("_", for: .normal)
            button.backgroundColor = .clear
            button.isUserInteractionEnabled = false
            break
        }
    }
    
    func setup(imageView: UIImageView, forState state: ButtosStates) {
           switch state {
           case .Receive:
               imageView.tintColor = .systemRed
               break
           case .Received, .Inaccessible:
                imageView.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
           }
    }
}
