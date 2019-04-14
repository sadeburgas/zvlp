 //
//  ThoughtCell.swift
//  ZVLP
//
//  Created by sade on 13/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

 protocol ThoughtDelegate {
    func thoughtOptionsTapped(thought: Thought)
 }
 
class ThoughtCell: UITableViewCell {

    // Outlets
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var thoughtTxtLbl: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likesNumLbl: UILabel!
    @IBOutlet weak var commentsNumLbl: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    
    // Variables
    private var thought: Thought!
    private var delegate:ThoughtDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
    }
    
    @objc func likeTapped() {
        Firestore.firestore().document("thoughts/\(thought.documentId!)")
            .updateData([NUM_LIKES : thought.numLikes + 1])
    }
    
    func configureCell(thought: Thought, delegate: ThoughtDelegate?) {
        optionsMenu.isHidden = true
        self.thought = thought
        self.delegate = delegate
        usernameLbl.text = thought.username
        thoughtTxtLbl.text = thought.thoughtTxt
        likesNumLbl.text = String(thought.numLikes)
        commentsNumLbl.text = String(thought.numComments)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm:ss"
        let timestamp = formatter.string(from: thought.timestamp as Date)
        
        print("timestamp: \(timestamp)")
        timestampLbl.text = timestamp
        
        if thought.userId == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(thoughtOptionsTapped))
            optionsMenu.addGestureRecognizer(tap)
            
        }
    }
    
    @objc func thoughtOptionsTapped(){
        delegate?.thoughtOptionsTapped(thought: thought)
    }
    
    
    
    
}
