//
//  CreateUserVC.swift
//  ZVLP
//
//  Created by sade on 17/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateUserVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10

      
    }
    
    @IBAction func createTapped(_ sender: Any) {
        
        guard let email = emailTxt.text,
            let password = passwordTxt.text,
            let username = usernameTxt.text else { return }
        if #available(iOS 12.0, *) {
            passwordTxt.textContentType = .oneTimeCode
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error creating user: \(error.localizedDescription)")
            }
            
            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            })
            
            guard let userId = user?.user.uid else { return }
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USERNAME : username,
                DATE_CREATED : FieldValue.serverTimestamp()
                ], completion: { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
            })
           
        }
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
