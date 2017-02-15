//
//  FeedViewController.swift
//  AC3.2-Final
//
//  Created by Cris on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

fileprivate let cellID = "feedReuseID"

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var databaseReference: FIRDatabaseReference!
    fileprivate let storage = FIRStorage.storage()
    @IBOutlet weak var feedtableView: UITableView!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = FIRDatabase.database().reference().child("posts")
        feedtableView.estimatedRowHeight = 450
        feedtableView.rowHeight = UITableViewAutomaticDimension
        feedtableView.delegate = self
        feedtableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDatabaseContent()
    }

    func getDatabaseContent() {
        self.databaseReference.observeSingleEvent(of: .value, with: { (snapShot) in
            for child in snapShot.children {
                if let snap = child as? FIRDataSnapshot,
                    let valueDict = snap.value as? [String : String] {
                    guard let comment = valueDict["comment"] else { return }
                    let post = Post(key: snap.key, comment: comment)
                    self.posts.append(post)
                }
            }
            self.feedtableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedtableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FeedTableViewCell
        let post = posts[indexPath.row]
        cell.commentLabel.text = post.comment
        let storageReference = storage.reference().child("images/\(post.key)")
        storageReference.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                cell.feedImageView.image = image
            }
        }
        return cell
    }
}
