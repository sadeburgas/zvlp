//
//  Thought.swift
//  ZVLP
//
//  Created by sade on 13/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import Foundation
import Firebase

class Thought {
    
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var thoughtTxt: String!
    private(set) var numLikes: Int!
    private(set) var numComments: Int!
    private(set) var documentId: String!
    private(set) var userId:String!
    
    init(username: String, timestamp: Date, thoughtTxt: String, numLikes: Int, numComments: Int, documentId: String, userId: String ) {
        
        self.username = username
        self.timestamp = timestamp
        self.thoughtTxt = thoughtTxt
        self.numLikes = numLikes
        self.numComments = numComments
        self.documentId = documentId
        self.userId = userId
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Thought] {
        var thoughts = [Thought]()
        
        guard let snap = snapshot else { return thoughts }
        for document in snap.documents {
            
            let data = document.data()
            
            let username = data[USERNAME] as? String ?? "Anonymous"
            
            let timestamp: Timestamp = data[TIMESTAMP] as? Timestamp  ?? Timestamp()
            let date: Date = timestamp.dateValue()
            
            //let timestamp = data[TIMESTAMP] as? Date ?? Date()
            let thoughtTxt = data[THOUGHT_TXT] as? String ?? ""
            let numLikes = data[NUM_LIKES] as? Int ?? 0
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newThought = Thought(username: username, timestamp: date, thoughtTxt: thoughtTxt, numLikes: numLikes, numComments: numComments, documentId: documentId, userId: userId)
            
            thoughts.append(newThought)
            
            print("document \(data)")
        }
        
        return thoughts
    }
    
    
    
    
}
