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
    
    private let errorBorderWidth: CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        ResetUIProperties()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hides the keyboard when the "return" key is pressed
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
        // Set border width of all textfields to zero and hide the error label
        errorLabel.isHidden = true
        usernameTextfield.layer.borderWidth = 0.0
        emailTextfield.layer.borderWidth = 0.0
        passwordTextfield.layer.borderWidth = 0.0
        confirmPasswordTextfield.layer.borderWidth = 0.0
    }
    
    func CheckDataCorrectness() -> Bool {
        //
        // Check each textfield for presence of all required information.
        // If any information is missing from a textfield, show a red border around it
        //
        if  usernameTextfield.text!.isEmpty ||
            emailTextfield.text!.isEmpty    ||
            passwordTextfield.text!.isEmpty ||
            confirmPasswordTextfield.text!.isEmpty {
            
            if usernameTextfield.text!.isEmpty {
                usernameTextfield.layer.borderWidth = errorBorderWidth
                usernameTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if emailTextfield.text!.isEmpty {
                emailTextfield.layer.borderWidth = errorBorderWidth
                emailTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if passwordTextfield.text!.isEmpty {
                passwordTextfield.layer.borderWidth = errorBorderWidth
                passwordTextfield.layer.borderColor = UIColor.red.cgColor
            }
            if confirmPasswordTextfield.text!.isEmpty {
                confirmPasswordTextfield.layer.borderWidth = errorBorderWidth
                confirmPasswordTextfield.layer.borderColor = UIColor.red.cgColor
            }
            
            errorLabel.text = "Missing required information"
            return false
        }
        
        // If passwords in the "password" and "confirm password" textfields don't match
        if passwordTextfield.text! != confirmPasswordTextfield.text! {
            errorLabel.text = "Passwords don't match"
            
            passwordTextfield.layer.borderWidth = errorBorderWidth
            passwordTextfield.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextfield.layer.borderWidth = errorBorderWidth
            confirmPasswordTextfield.layer.borderColor = UIColor.red.cgColor
            return false
        }
        
        return true
    }
}
