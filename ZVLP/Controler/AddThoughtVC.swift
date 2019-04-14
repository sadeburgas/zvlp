//
//  AddThoughtVC.swift
//  ZVLP
//
//  Created by sade on 12/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import Firebase

class AddThoughtVC: UIViewController, UITextViewDelegate {
    
    // Outlets
    @IBOutlet private weak var categorySegment: UISegmentedControl!
    @IBOutlet private weak var thoughtTxt: UITextView!
    @IBOutlet private weak var postBtn: UIButton!
    
    //Variables
    private var selectedCategory = ThoughtCategory.funny.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()
        postBtn.layer.cornerRadius = 4
        thoughtTxt.layer.cornerRadius = 4
        thoughtTxt.text = "My random though..."
        thoughtTxt.textColor = UIColor.lightGray
        thoughtTxt.delegate = self

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.darkGray
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        switch categorySegment.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1:
            selectedCategory = ThoughtCategory.serious.rawValue
        default:
            selectedCategory = ThoughtCategory.crazy.rawValue
        }
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
    
        Firestore.firestore().collection(THOUGHT_REF).addDocument(data: [
            CATEGORY : selectedCategory,
            NUM_COMMENTS : 0,
            NUM_LIKES : 0,
            THOUGHT_TXT : thoughtTxt.text!,
            TIMESTAMP : FieldValue.serverTimestamp(),
            USERNAME : Auth.auth().currentUser?.displayName ?? "",
            USER_ID: Auth.auth().currentUser?.uid ?? ""
            
        ]) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    

}
