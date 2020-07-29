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
    @IBOutlet weak var changeAuthorizationButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var footerView: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var promocode: UITextField!
    @IBOutlet weak var bottomStackViewConstraints: NSLayoutConstraint!
    
    var ref: DatabaseReference!
    
    var authorizationState: AuthorizationState = .singIn
    var oldFooterHeight: CGFloat = 0
    var oldCornerRadius: CGFloat = 0
    var oldBottomStackViewConstraints: CGFloat = 0
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        footerView.layer.cornerRadius = 40
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
        
        changeAuthorizationButton.setTitleColor(#colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1), for: .normal)
        
        if authorizationState == .singIn {
            resetPasswordButton.setTitleColor(#colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1), for: .normal)
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: email.bounds.height - 20, width: email.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        email.borderStyle = UITextField.BorderStyle.none
        email.layer.addSublayer(bottomLine)
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.bounds.width, height: 1.0)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        password.borderStyle = UITextField.BorderStyle.none
        password.layer.addSublayer(bottomLine2)
        
        if authorizationState == .signUp {
            let bottomLine3 = CALayer()
            bottomLine3.frame = CGRect(x: 0.0, y: promocode.bounds.height - 20, width: promocode.bounds.width, height: 1.0)
            bottomLine3.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            promocode.borderStyle = UITextField.BorderStyle.none
            promocode.layer.addSublayer(bottomLine3)
        }
        
        oldBottomStackViewConstraints = bottomStackViewConstraints.constant
        oldFooterHeight = footerHeight.constant
        oldCornerRadius = footerView.layer.cornerRadius
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    
//    MARK:- Handle keyboard up/down
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let keyboardHeight = keyboardRectangle.height
            
            print("\n\nHeight: \(keyboardHeight) \n\n")
            
            footerHeight.constant =  UIScreen.main.bounds.height
            bottomStackViewConstraints.constant = -keyboardHeight - 10
            
            footerView.layer.cornerRadius =  0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
            super.touchesBegan(touches, with: event)
            

            bottomStackViewConstraints.constant = oldBottomStackViewConstraints
            footerView.layer.cornerRadius = oldCornerRadius
            footerHeight.constant =  oldFooterHeight
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    
    
//    MARK:- Handle SignIn/SignUp
    
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
                    self?.showAlert(title: "Не получается зарегистрироваться", message: "Неправильная почта", buttonText: "ok")
                   case .networkError:
                    self?.showAlert(title: "Не получается зарегистрироваться", message: "Ошибка интернета, попробуйте снова", buttonText: "ok")
                       
                   default:
                    self?.showAlert(title: "Не получается зарегистрироваться", message: "Внутренняя ошибка, попробуйте снова", buttonText: "ok")
                       break
                   }
                }
            }
            
            if let user = authResult?.user {
                let userRef = self?.ref.child(user.uid)
                
                userRef?.setValue(["email": email, "username": "", "uid": user.uid, "refCode": String(self?.promocode.text  ?? "_"), "energyCurrency": 0, "heartCurrency": 0, "didAddreferalBonus": false, "bonusTime": "", "heartBonusTime": ""])

                self?.performSegue(withIdentifier: "moveToMainScreen", sender: self)
            }
        })
    }
    
    
//  MARK:- Reset password
    
    @IBAction func resetPasswordTapped(sender: UIButton) {
        
        let alert = UIAlertController(title: "Сбросить пароль", message: "Пожалуйста, введите вашу почту", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
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
    
    
//  Change authorization type
    
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
