//
//  SignupScreenViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/11/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class SignupScreenViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        ResetUIProperties()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func Signup(_ sender: UIButton) {
        ResetUIProperties()
        if CheckDataCorrectness() == false {
            errorLabel.isHidden = false
            return
        }
        
        LoginManager.SignupUser(username: usernameTextfield.text!, email: emailTextfield.text!, password: passwordTextfield.text!, view: self) { succeeded, error, errorString  in
            if (succeeded) {
                UIUtils.showAlert(view: self, title: "Success", message: "You have successfully registered!") {
                    self.performSegue(withIdentifier: "ReturnToLoginScreenSegue", sender: nil)
                }
            }
            else {
                if errorString != nil {
                    if errorString! == "Username taken" {
                        self.errorLabel.text = "Username taken"
                    } else {
                        self.errorLabel.text = "Error occured"
                    }
                    self.errorLabel.isHidden = false
                }
            }
            
            if error != nil {
                UIUtils.showAlert(view: self, title: "Connection Failed", message: "Failed to connect to the server")
            }
        }
    }
    
    func ResetUIProperties() {
        errorLabel.isHidden = true
        usernameTextfield.layer.borderWidth = 0.0
        emailTextfield.layer.borderWidth = 0.0
        passwordTextfield.layer.borderWidth = 0.0
        confirmPasswordTextfield.layer.borderWidth = 0.0
    }
    
    func CheckDataCorrectness() -> Bool {
        if  usernameTextfield.text!.isEmpty ||
            emailTextfield.text!.isEmpty    ||
            passwordTextfield.text!.isEmpty ||
            confirmPasswordTextfield.text!.isEmpty {
            
            if usernameTextfield.text!.isEmpty {
                usernameTextfield.layer.borderWidth = 1.0
                usernameTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if emailTextfield.text!.isEmpty {
                emailTextfield.layer.borderWidth = 1.0
                emailTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if passwordTextfield.text!.isEmpty {
                passwordTextfield.layer.borderWidth = 1.0
                passwordTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if confirmPasswordTextfield.text!.isEmpty {
                confirmPasswordTextfield.layer.borderWidth = 1.0
                confirmPasswordTextfield.layer.borderColor = UIColor.red.cgColor
            }
            
            errorLabel.text = "Missing required information"
            return false
        }
        
        if passwordTextfield.text! != confirmPasswordTextfield.text! {
            errorLabel.text = "Passwords don't match"
            
            passwordTextfield.layer.borderWidth = 1.0
            passwordTextfield.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextfield.layer.borderWidth = 1.0
            confirmPasswordTextfield.layer.borderColor = UIColor.red.cgColor
            return false
        }
        
        return true
    }
}
