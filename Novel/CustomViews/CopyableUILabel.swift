//
//  CopyableUILabel.swift
//  Novel
//
//  Created by Иван Абрамов on 16.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

class CopyableUILabel: UILabel {

  override public var canBecomeFirstResponder: Bool {
      get {
          return true
      }
  }

  override init(frame: CGRect) {
      super.init(frame: frame)
      sharedInit()
  }

  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      sharedInit()
  }

  func sharedInit() {
      isUserInteractionEnabled = true
      addGestureRecognizer(UILongPressGestureRecognizer(
          target: self,
          action: #selector(showMenu(sender:))
      ))
  }

  override func copy(_ sender: Any?) {
      UIPasteboard.general.string = text
      UIMenuController.shared.hideMenu()
  }

  @objc func showMenu(sender: Any?) {
      becomeFirstResponder()
      let menu = UIMenuController.shared
      if !menu.isMenuVisible {
        menu.showMenu(from: self, rect: bounds)
      }
  }

  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
      return (action == #selector(copy(_:)))
  }
}

