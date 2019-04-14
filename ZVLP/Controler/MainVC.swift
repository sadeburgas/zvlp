//
//  MainVC.swift
//  ZVLP
//
//  Created by sade on 10/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import RevealingSplashView

enum ThoughtCategory : String {
    case serious = "serious"
    case funny = "funny"
    case crazy = "crazy"
    case popular = "popular"
}

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ThoughtDelegate {
    

    
    
    // Outlets
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!

    // Variables
    private var thoughts = [Thought]()
    private var thoughtsCollectionRef: CollectionReference!
    private var thoughtsListener: ListenerRegistration!
    private var selectedCategory = ThoughtCategory.funny.rawValue
    private var handle: AuthStateDidChangeListenerHandle?
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        thoughtsCollectionRef = Firestore.firestore().collection(THOUGHT_REF)
        
        revealingSplashView.heartAttack = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC!, animated: true, completion: nil)
            } else {
                  self.setListener()
            }
        })
    }
    
    
    func thoughtOptionsTapped(thought: Thought) {
        // This is where we create the alert to handle the deletion.
        print(thought.username!)
        print(thought.thoughtTxt!)
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete your thought?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Thought", style: .default) { (action) in
            // delete thought
            
            self.delete(collection: Firestore.firestore().collection(THOUGHT_REF).document(thought.documentId).collection(COMMENTS_REF), completion: { (error) in
                if let error = error {
                    debugPrint("Could not delete subcolection: \(error.localizedDescription)")
                } else {
                    
                    Firestore.firestore().collection(THOUGHT_REF).document(thought.documentId).delete(completion: { (error) in
                        if let error = error {
                            debugPrint("Could not delete thought: \(error.localizedDescription)")
                        } else {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    })
                    
                }
            })
            

        }
        let canselAction = UIAlertAction(title: "Cansel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(canselAction)
        present(alert, animated: true
            , completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if thoughtsListener != nil {
            thoughtsListener.remove()
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signoutError as NSError {
            debugPrint("Error signing out: \(signoutError)" )
        }
        
    }
    
    func setListener() {
        
        if selectedCategory == ThoughtCategory.popular.rawValue {
            thoughtsListener = thoughtsCollectionRef
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let err = error {
                        debugPrint("Error fetching docs: \(err)")
                    } else {
                        self.thoughts.removeAll()
                        self.thoughts = Thought.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
            }
            
        } else {
            thoughtsListener = thoughtsCollectionRef
                .whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let err = error {
                        debugPrint("Error fetching docs: \(err)")
                    } else {
                        self.thoughts.removeAll()
                        self.thoughts = Thought.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
            }
            
        }
    }
    
    func delete(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()){
        // Limit query to avoid out-of-memory errors on large collections.
        // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            // An error ocurred.
            guard let docset = docset else {
                completion(error)
                return
            }
            // There's nothing to delete.
            guard docset.count > 0 else {
                completion(nil)
                return
            }
            
            let batch = collection.firestore.batch()
            docset.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { (batchError) in
                if let batchError = batchError {
                    // Stop the deletion process and handle the error. Some elements
                    // may have been deleted.
                    completion(batchError)
                } else {
                    self.delete(collection: collection, batchSize: batchSize, completion: completion)
                }
            }
        }
        
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1:
            selectedCategory = ThoughtCategory.serious.rawValue
        case 2:
            selectedCategory = ThoughtCategory.crazy.rawValue
        default:
            selectedCategory = ThoughtCategory.popular.rawValue
        }
        
        thoughtsListener.remove()
        setListener()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as? ThoughtCell {
            
            cell.configureCell(thought: thoughts[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: thoughts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let thought = sender as? Thought {
                    destinationVC.thought = thought
                }
            }
        }
    }


}

