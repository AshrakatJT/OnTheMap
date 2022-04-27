//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 21/03/2022.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginIndicator: UIActivityIndicatorView!
        
    override func viewDidLoad () {
        super.viewDidLoad()
        setUpTextFields()
        email.text = ""
        password.text = ""
        loginIndicator.isHidden = true
        email.delegate = self
        password.delegate = self
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpTextFields()
        subscribeToKeyboardNotifications()
        navigationController?.navigationBar.isHidden = true
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }

    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            print(UdacityClient.Auth.sessionId)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "tabBarSegue", sender: nil)
            }
            
        } else {
            email.resignFirstResponder()
            password.resignFirstResponder()
            userAlert(message: error?.localizedDescription ?? "")
        }
    }
    
    
    @IBAction func login(_ sender:UIButton) {
        if (email.text?.isEmpty)! || (password.text?.isEmpty)! {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Required fields", message: "please enter a username or password", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            setLoggingIn(true)
            UdacityClient.login(username: email.text ?? "", password: password.text ?? "", completion: handleLoginResponse(success:error:))
            
        }
    }
    
    
    
    @IBAction func signUp(_ sender: Any) {
        setLoggingIn(true)
        UIApplication.shared.open(UdacityClient.EndPoints.webAuth.url, options: [:], completionHandler: nil)
        setLoggingIn(false)
    }
    
    func userAlert(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction (UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag){
        nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
            return true
        }
    
    func setUpTextFields() {
        email.textColor = .black
        password.textColor = .black
    }
    
    func setLoggingIn(_ loggingIn : Bool){
        if loggingIn {
            DispatchQueue.main.async {
                self.loginIndicator.stopAnimating()
            }
        }
        email.isEnabled = !loggingIn
        password.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
        loginIndicator.isHidden = !loggingIn
    }

func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
}
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification:Notification){
        if password.isEditing || email.isEditing{
            view.frame.origin.y -= getKeyboardHeight (notification)
    }
    }
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

}
