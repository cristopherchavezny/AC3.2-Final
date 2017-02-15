//
//  UploadViewController.swift
//  AC3.2-Final
//
//  Created by Cris on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    var databaseReference: FIRDatabaseReference!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = FIRDatabase.database().reference().child("posts/")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        uploadImageView.addGestureRecognizer(gesture)
    }
    
    func didTapImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [String(kUTTypeImage)]
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        switch info[UIImagePickerControllerMediaType] as! String {
        case String(kUTTypeImage):
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                selectedImage = image
            }
        default:
            print("INVALID MEDIA TYPE")
        }
        dismiss(animated: true) { 
            guard let image = self.selectedImage else {return }
            self.uploadImageView.image = image
        }
    }
    
    func checkIfAllFieldsHaveContent() -> Bool {
        guard !commentTextView.text.isEmpty,
            self.selectedImage != nil else { return false }
        return true
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if checkIfAllFieldsHaveContent() {
            shareToFirebase()
        } else {
            self.showAlert(title: "Upload Failed!!!", errorMessage: "You must pick a photo")
        }
    }
    
    func shareToFirebase() {
        let linkRef = self.databaseReference.childByAutoId()
        let storage = FIRStorage.storage()
        let storageReference = storage.reference(forURL: "gs://ac-32-final.appspot.com/")
        let spaceRef = storageReference.child("images/\(linkRef.key)")
        guard let validImage = selectedImage else { return }
        let jpeg = UIImageJPEGRepresentation(validImage, 0.70)
        
        let metadata = FIRStorageMetadata()
        metadata.cacheControl = "public, max-age=300"
        metadata.contentType = "image/jpeg"
        
        let _ = spaceRef.put(jpeg!, metadata: metadata) { (metadata, error) in
            guard metadata != nil else { print("put error"); return }
        }
        
        let dict = [
                    "comment" : commentTextView.text,
                    "userId" :  FIRAuth.auth()?.currentUser?.uid
                    ]
        
        linkRef.setValue(dict) { (error, reference) in
            if let error = error {
                print(error)
                self.showAlert(title: "Upload Failed!!!", errorMessage: "IDK")
            } else {
                print(reference)
                self.showAlert(title: "Upload Successful!", errorMessage: error?.localizedDescription)
            }
        }
    }
    
    func showAlert(title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
