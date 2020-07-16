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
    @IBOutlet weak var promocode: UITextField!
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
                   promocode.tintColor = .gray
                   promocode.setIcon(image)
            }
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: email.bounds.height - 20, width: email.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        email.borderStyle = UITextField.BorderStyle.none
        email.layer.addSublayer(bottomLine)
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.bounds.width, height: 1.0)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        password.borderStyle = UITextField.BorderStyle.none
        password.layer.addSublayer(bottomLine2)
        
        if authorizationState == .signUp {
            let bottomLine3 = CALayer()
            bottomLine3.frame = CGRect(x: 0.0, y: promocode.bounds.height - 20, width: promocode.bounds.width, height: 1.0)
            bottomLine3.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
            promocode.borderStyle = UITextField.BorderStyle.none
            promocode.layer.addSublayer(bottomLine3)
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
        
        guard var email = email.text, !email.isEmpty else {
            showAlert(title: "Пустая почта", message: "Пожалуйста, введите вашу почту", buttonText: "ok")
            return
        }

        email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard var password = password.text, !password.isEmpty else {
            showAlert(title: "Пустой пароль", message: "Пожалуйста, введите ваш пароль", buttonText: "ok")
            return
        }

        password = password.trimmingCharacters(in: .whitespacesAndNewlines)


        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .wrongPassword:
                        self.showAlert(title: "Не получается войти", message: "Нерпавильный пароль", buttonText: "ok")
                        break
                    
                    case .userNotFound:
                    self.showAlert(title: "Не получается войти", message: "Аккаунт не найден", buttonText: "ok")
                    break
                    
                    case .invalidEmail:
                        self.showAlert(title: "Не получается войти", message: "Неправильная почта", buttonText: "ok")
                    
                    case .networkError:
                        self.showAlert(title: "Не получается войти", message: "Ошибка интернета, попробуйте снова", buttonText: "ok")
                        
                    default:
                        self.showAlert(title: "Не получается войти", message: "Внутренняя ошибка, попробуйте снова", buttonText: "ok")
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
        
        guard var email = email.text, !email.isEmpty else {
            showAlert(title: "Пустая почта", message: "Пожалуйста, введите вашу почту", buttonText: "ok")
            return
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard var password = password.text, !password.isEmpty else {
            showAlert(title: "Пустой пароль", message: "Пожалуйста, введите пароль", buttonText: "ok")
            return
        }
        
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion:  {  [weak self] (authResult, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                                   
                   switch errCode {
                   case .credentialAlreadyInUse, .emailAlreadyInUse:
                    self?.showAlert(title: "Не получается зарегистрироваться", message: "Аккаунт с такой почтой уже существует", buttonText: "ok")
                       break
                   case .weakPassword:
                    self?.showAlert(title: "Не получается зарегистрироваться", message: "Пароль должен содержать минимум 6 символов", buttonText: "ok")
                                         break
                   case .invalidEmail:
                    self?.showAlert(title: "Не получается войти", message: "Неправильная почта", buttonText: "ok")
                   case .networkError:
                    self?.showAlert(title: "Не получается войти", message: "Ошибка интернета, попробуйте снова", buttonText: "ok")
                       
                   default:
                    self?.showAlert(title: "Не получается войти", message: "Внутренняя ошибка, попробуйте снова", buttonText: "ok")
                       break
                   }
                }
            }
            
            if let user = authResult?.user {
                let userRef = self?.ref.child(user.uid)
                
                userRef?.setValue(["email": email, "username": self?.promocode.text ?? "", "uid": user.uid, "refCode": self?.promocode.text ?? "_", "diamondCurrency": 0, "ticketCurrency": 0, "didAddreferalBonus": false])

                self?.performSegue(withIdentifier: "moveToMainScreen", sender: self)
            }
        })
    }
    
    
    @IBAction func resetPasswordTapped(sender: UIButton) {
        
        let alert = UIAlertController(title: "Сбросить пароль", message: "Пожалуйста, введите вашу почту", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler:nil))
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
            if error != nil {
                self.showAlert(title: "Не удается сбросить пароль", message: error?.localizedDescription ?? "Попробуйте снова", buttonText: "Ок")
            }
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
