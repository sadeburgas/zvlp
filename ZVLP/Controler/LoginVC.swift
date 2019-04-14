//
//  LoginVC.swift
//  ZVLP
//
//  Created by sade on 17/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createUserBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 10
        createUserBtn.layer.cornerRadius = 10

    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        guard let email = emailTxt.text,
            let password = passwordTxt.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing in: \(error)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createUserTapped(_ sender: Any) {
        
    }
    
}
