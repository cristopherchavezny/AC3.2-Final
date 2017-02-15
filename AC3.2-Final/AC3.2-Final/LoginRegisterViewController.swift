//
//  LoginRegisterViewController.swift
//  AC3.2-Final
//
//  Created by Cris on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginRegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func getTextFromTextFields() -> (email: String, password: String)? {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return nil}
        return (email, password)
    }
    
    func showAlert(title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let credentials = getTextFromTextFields() else { return }
        FIRAuth.auth()?.createUser(withEmail: credentials.email, password: credentials.password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                self.showAlert(title: "Registration Error", errorMessage: error?.localizedDescription)
            }
            if let user = user {
                print(user.email!)
            }
        })
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let credentials = getTextFromTextFields() else { return }
        FIRAuth.auth()?.signIn(withEmail: credentials.email, password: credentials.password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                self.showAlert(title: "Login Error", errorMessage: error?.localizedDescription)
            }
            guard user != nil else { return }
                let alert = UIAlertController(title: "Login Successful!", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "SegueToFeedVC", sender: action)
                
                
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
