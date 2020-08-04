//
//  CharacterStyleViewController.swift
//  Novel
//
//  Created by Иван Абрамов on 29.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

enum StyleState {
    case gender
    case race
    case hair
}

protocol CharacterStyleViewControllerDelegate: class {
    func saveNew(styleWithModel model: [StyleState: String])
}

class CharacterStyleViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var footerView: UIImageView!
    @IBOutlet weak var headerInFooterView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    var delegate: CharacterStyleViewControllerDelegate?
    
    var currentState: StyleState = .gender {
        willSet(value) {
            if let sequenceNumber = styleArray[value]?.firstIndex(of: styleModel[value] ?? "") {
                setupView(forstate: value, andSequenceNumber: sequenceNumber)
            } else {
                setupView(forstate: value, andSequenceNumber: 0)
            }
        }
    }
    var currentSequenceNumber = 0
    
    let styleArray = [
        StyleState.gender: ["мужчина", "женщина"],
        StyleState.race: ["европеец", "азиат", "негроид"],
        StyleState.hair: ["короткие", "длинные", "каре"]
    ]
    
    var styleModel = [
        StyleState.gender: "женщина",
        StyleState.race:   "европеец",
        StyleState.hair:   "длинные"
    ]
    
    @IBAction func chooseTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            currentState = .gender
        case 1:
            currentState = .race
        case 2:
            currentState = .hair
        default:
            break
        }
    }
    
    func setupView(forstate state: StyleState, andSequenceNumber sequenceNumber: Int) {
        textLabel.text = styleArray[state]?[sequenceNumber]
        
        styleModel[state] = textLabel.text
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        print("\n\nDismiss\n\n")
        
        delegate?.saveNew(styleWithModel: styleModel)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        guard let currentstyleDescriptions = styleArray[currentState] else { return }
        let nextSequenceNumber = (currentSequenceNumber - 1).mod(currentstyleDescriptions.count)
        currentSequenceNumber = nextSequenceNumber
        
        setupView(forstate: currentState, andSequenceNumber: currentSequenceNumber)
    }
    
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        guard let currentstyleDescriptions = styleArray[currentState] else { return }
        let nextSequenceNumber = (currentSequenceNumber + 1) % currentstyleDescriptions.count
        currentSequenceNumber = nextSequenceNumber
        
        setupView(forstate: currentState, andSequenceNumber: currentSequenceNumber)
    }
    
    func configuregestureRecognizers() {
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftGestureHandler))
        leftGesture.direction = .left
        self.view.addGestureRecognizer(leftGesture)
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightGestureHandler))
        rightGesture.direction = .right
        
        self.view.addGestureRecognizer(rightGesture)
    }
    
    @objc func leftGestureHandler() {
        leftButtonTapped(self)
    }
    
    @objc func rightGestureHandler() {
        rightButtonTapped(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentState = .gender
        currentSequenceNumber = 0
        
        headerInFooterView.layer.cornerRadius = 40
        headerInFooterView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        configuregestureRecognizers()
    }
}

extension Int {
    func mod(_ n: Int) -> Int {
        let r = self % n
        return r >= 0 ? r : r + n
    }
}
