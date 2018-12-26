//
//  RegisterViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-21.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var changeProfilePicture: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nameField: LoginField!
    @IBOutlet weak var emailField: LoginField!
    @IBOutlet weak var passwordField: LoginField!
    @IBOutlet weak var rePasswordField: LoginField!
    
    @IBOutlet weak var changeProfileTop: NSLayoutConstraint!
    @IBOutlet weak var changeProfileLeft: NSLayoutConstraint!
    
    var uploadPicture: Bool = false
    let imageController = UIImagePickerController()
        
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
        
        changeProfilePicture.layer.cornerRadius = changeProfilePicture.frame.height/2
        
        registerButton.layer.cornerRadius = registerButton.frame.height/2
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changePicture))
        profilePicture.addGestureRecognizer(gesture)
        profilePicture.isUserInteractionEnabled = true
        changeProfilePicture.addTarget(self, action: #selector(changePicture), for: .touchUpInside)
        
        loadingView.layer.cornerRadius = 10
        stopLoading()
        constrainProfileButton()
    }
    
    func constrainProfileButton(){
        let r = profilePicture.frame.width/2
        let x = r-(r*CGFloat(cos((0.25)*(Double.pi))))
        let y = r-(r*CGFloat(sin((0.25)*(Double.pi))))
        
        changeProfileTop.constant = -y
        changeProfileLeft.constant = -x
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        stopLoading()
        if nameField.text == "" || emailField.text == "" || passwordField.text == "" || rePasswordField.text == ""{
            self.displayError(title: "Registration Error", description: "Empty fields")
            return
        }
        if passwordField.text != rePasswordField.text{
            self.displayError(title: "Registration Error", description: "Passwords dont match")
            return
        }
        
        startLoading()
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (authResult, error) in
            if let err = error{
                self.stopLoading()
                self.displayError(title: "Registration Error", description: err.localizedDescription)
                return
            }
            if self.uploadPicture{
                guard let uid = authResult?.user.uid else {self.stopLoading();return}
                let storageRef = Storage.storage().reference(withPath: "Pictures/\(uid).jpeg")
                let uploadMetadata = StorageMetadata()
                uploadMetadata.contentType = "image/jpeg"
                
                guard let data = self.profilePicture.image!.jpegData(compressionQuality: 0.8) else{self.stopLoading();return}
                
                let uploadTask = storageRef.putData(data, metadata: uploadMetadata, completion: { (metaData, error) in
                    if let err = error{
                        self.stopLoading()
                        self.displayError(title: "Registration Error", description: err.localizedDescription)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = error{
                            self.stopLoading()
                            self.displayError(title: "Registration Error", description: err.localizedDescription)
                            return
                        }
                        
                        let urlString = url?.absoluteString
                        let user = User(ID: uid, name: self.nameField.text!, profileURL: urlString, facebookID: nil)
                        DatabaseHelper.storeUser(user: user)
                        self.stopLoading()
                    })
                    
                })
                
                uploadTask.observe(.progress, handler: {[weak self] (snapshot) in
                    guard let strongSelf = self else{return}
                    guard let progress = snapshot.progress else{return}
                    strongSelf.progressView.progress = Float(progress.fractionCompleted)
                })
            }
            else{
                guard let uid = authResult?.user.uid else {self.stopLoading();return}
                let user = User(ID: uid, name: self.nameField.text!)
                DatabaseHelper.storeUser(user: user)
                self.stopLoading()
            }
        }
    }
    
    @objc func changePicture(){
        let alert = UIAlertController(title: nil, message: "Please select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.imageController.delegate = self
            self.imageController.allowsEditing = true
            self.imageController.sourceType = .camera
            self.present(self.imageController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.imageController.delegate = self
            self.imageController.allowsEditing = true
            self.present(self.imageController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var image:UIImage
        
        if let imageEdited = info[.editedImage] as? UIImage{
            image = imageEdited
        }
        else if let imageOriginal = info[.originalImage] as? UIImage{
            image = imageOriginal
        }else{
            dismiss(animated:true)
            return
        }
        
        self.uploadPicture = true
        self.profilePicture.image = image
        dismiss(animated:true)
        
    }
    
    func startLoading(){
        DispatchQueue.main.async {
            self.loadingView.alpha = 1
            self.loadingIcon.startAnimating()
        }
    }
    
    func stopLoading(){
        DispatchQueue.main.async {
            self.loadingView.alpha = 0
            self.loadingIcon.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
