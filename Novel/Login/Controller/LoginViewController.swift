//
//  LoginViewController.swift
//  ToDO
//
//  Created by Иван Абрамов on 26.03.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//
import UIKit
import Firebase

// Enum  for checkbox states
public enum AuthorizationState {
    case signUp
    case singIn
}

//var accounts: Results<Category>!

class LoginViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var footerView: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var bottomButtonConstraints: NSLayoutConstraint!
    
    var ref: DatabaseReference!
    
    var authorizationState: AuthorizationState = .singIn
    var oldFooterHeight: CGFloat = 0
    var oldCornerRadius: CGFloat = 0
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        footerView.layer.cornerRadius = 50
        footerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        footerView.clipsToBounds = true
        
        
        if let image = UIImage(named: "email") {
            email.tintColor = .gray
            email.setIcon(image)
        }
        
        
        if let image = UIImage(named: "password") {
                   password.tintColor = .gray
                   password.setIcon(image)
        }
        
        
        if let image = UIImage(named: "username") {
            if authorizationState == .signUp {
                   username.tintColor = .gray
                   username.setIcon(image)
            }
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: email.bounds.height - 20, width: email.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        email.borderStyle = UITextField.BorderStyle.none
        email.layer.addSublayer(bottomLine)
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.frame.width, height: 1.0)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        password.borderStyle = UITextField.BorderStyle.none
        password.layer.addSublayer(bottomLine2)
        
        if authorizationState == .signUp {
            let bottomLine3 = CALayer()
            bottomLine3.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.frame.width, height: 1.0)
            bottomLine3.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
            username.borderStyle = UITextField.BorderStyle.none
            username.layer.addSublayer(bottomLine2)
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    

    
    @IBAction func tapAction(_ sender: Any) {
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
            
//            let keyboardHeight = keyboardRectangle.height
            
//            print("Height: \(keyboardHeight)")
            
            guard oldFooterHeight == 0 else { return }
            
//            guard keyboardHeight != 0 else { return }
            
            var constant = CGFloat(0)
            
            if authorizationState == .singIn {
                constant = CGFloat(75.0)
            }
            
            oldCornerRadius = footerView.layer.cornerRadius
            footerView.layer.cornerRadius =  0
            
            oldFooterHeight = footerHeight.constant
            footerHeight.constant = footerHeight.constant + abs(footerView.frame.size.height - (sendButton.frame.size.height + sendButton.frame.origin.y))
            
            footerHeight.constant = footerHeight.constant - constant
            
            UIView.animate(withDuration: 2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func singIn(_ sender: Any) {
        
        guard var email = email.text else {
            showAlert(title: "No email supplied", message: "Please, enter email", buttonText: "ok")
            return
        }

        email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard var password = password.text else {
            showAlert(title: "No password supplied", message: "Please, enter password", buttonText: "ok")
            return
        }

        password = password.trimmingCharacters(in: .whitespacesAndNewlines)


        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .wrongPassword:
                        self.showAlert(title: "Cannot authorize", message: "Yor password is incorrect", buttonText: "ok")
                        break
                    
                    case .userNotFound:
                    self.showAlert(title: "Cannot authorize", message: "Account not found", buttonText: "ok")
                    break
                    
                    case .invalidEmail:
                        self.showAlert(title: "Cannot authorize", message: "Invalid email", buttonText: "ok")
                    
                    case .networkError:
                        self.showAlert(title: "Cannot authorize", message: "Network error, try again", buttonText: "ok")
                        
                    default:
                        self.showAlert(title: "Cannot authorize", message: "Internal error, try again", buttonText: "ok")
                        break
                    }
                }
            }

            if user != nil {
                self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        guard var email = email.text else {
            showAlert(title: "No email supplied", message: "Please, enter email", buttonText: "ok")
            return
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard var password = password.text else {
            showAlert(title: "No password supplied", message: "Please, enter password", buttonText: "ok")
            return
        }
        
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion:  {  [weak self] (authResult, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                                   
                   switch errCode {
                   case .credentialAlreadyInUse, .emailAlreadyInUse:
                    self?.showAlert(title: "Cannot register", message: "Account with same email already registered", buttonText: "ok")
                       break
                   case .weakPassword:
                    self?.showAlert(title: "Cannot register", message: "Weak password: minimal length is 6 characters", buttonText: "ok")
                                         break
                   case .invalidEmail:
                    self?.showAlert(title: "Cannot authorize", message: "Invalid email", buttonText: "ok")
                   case .networkError:
                    self?.showAlert(title: "Cannot authorize", message: "Network error, try again", buttonText: "ok")
                       
                   default:
                    self?.showAlert(title: "Cannot authorize", message: "Internal error, try again", buttonText: "ok")
                       break
                   }
                }
            }
            
            if let user = authResult?.user {
                let userRef = self?.ref.child(user.uid)
                userRef?.setValue(["email": email, "username": self?.username.text ?? "", "uid": user.uid, "refCode": user.uid, "diamondCurrency": 0, "ticketCurrency": 0])

                self?.performSegue(withIdentifier: "moveToMainScreen", sender: self)
            }
        })
    }
//
//    let uid: String
//    let email: String
//    let username: String
//    let refCode: String
//    let diamondCurrency: Int
//    let ticketCurrency: Int
    
    
    @IBAction func resetPasswordTapped(sender: UIButton) {
        
        let alert = UIAlertController(title: "Reset password", message: "Please, enter your email", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction)in
            if let email = alert.textFields?.first?.text {
                self.resetPassword(forEmail: email.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            }))
        
        self.present(alert, animated: true, completion: {
               
            })
    }
    
    func resetPassword(forEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.showAlert(title: "Не удается сбросить пароль", message: error?.localizedDescription ?? "Попробуйте снова", buttonText: "Ок")
        }
    }
    
    
    @IBAction func changeAuthorizationType(_ sender: Any) {
        if authorizationState == .signUp {
            performSegue(withIdentifier: "changeToSignIn", sender: self)
        } else {
            performSegue(withIdentifier: "changeToSignUp", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeToSignIn"  {
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .singIn
        }
        else if segue.identifier == "changeToSignUp" {
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .signUp
        }
    }
    
    func showAlert(title : String, message : String, buttonText : String) {
               let alert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
               
                           alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
               
                           self.present(alert, animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
        guard oldFooterHeight != 0 else { return }
        footerHeight.constant =  oldFooterHeight
        oldFooterHeight = 0
        footerView.layer.cornerRadius = oldCornerRadius
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension UITextField {
    func setIcon(_ image: UIImage) {
       let iconView = UIImageView(frame:
                      CGRect(x: 0, y: 2, width: 20, height: 20))
       iconView.image = image
       let iconContainerView: UIView = UIView(frame:
                      CGRect(x: 0, y: 0, width: 30, height: 30))
       iconContainerView.addSubview(iconView)
       leftView = iconContainerView
       leftViewMode = .always
    }
}
