//
//  LoginViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-19.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailField: LoginField!
    @IBOutlet weak var phoneField: LoginField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        loginButton.layer.cornerRadius = loginButton.frame.height/2
        loginButton.addGradient(color1: UIColor(rgb: 0x86BFFF), color2: UIColor(rgb: 0x3E72C3))
        loginButton.clipsToBounds = true
        facebookButton.layer.cornerRadius = facebookButton.frame.height/2
        facebookButton.clipsToBounds = true
        facebookButton.imageView!.contentMode = .scaleAspectFit
        facebookButton.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(regularLogin), for: .touchUpInside)

    }
    
    @objc func regularLogin(){
        if emailField.text == "" || phoneField.text == ""{
            displayError(title: "Login Error", description: "Empty fields")
            return
        }
        Auth.auth().signIn(withEmail: emailField.text!, password: phoneField.text!) { (authResult, error) in
            if let error = error{
                self.displayError(title: "Login Error", description: error.localizedDescription); return
            }
            //TODO: fetch user
            guard let uid = authResult?.user.uid else{return}
            DatabaseHelper.getUser(uid: uid, completion: { (user) in
                if let user = user{
                    UserSingleton.shared.user = user
                    UserSingleton.shared.downloadImage()
                    UserSingleton.shared.isLoggedIn = true
                    //TODO: perform segue
                }
            })
        }
    }
    
    @objc func facebookLogin(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let err = error{
                print("FACEBOOK LOGIN FAILED:", err.localizedDescription)
                return
            }
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"name, id"])?.start(completionHandler: { (connection, result, error) in
                if let err = error{
                    print("FAILED GRAPH REQUEST:", err.localizedDescription)
                    return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                    if let error = error{
                        print("ERROR SIGNING IN:", error.localizedDescription)
                        return
                    }
                    guard let result = result as? [String:Any] else{return}
                    guard let authResult = authResult else{return}
                    let user = User(ID: authResult.user.uid, name: result["name"] as? String ?? "")
                    if let fbID = result["id"] as? String{
                        user.facebookID = Int(fbID)
                    }
                    DatabaseHelper.storeUser(user: user)
                    UserSingleton.shared.user = user
                    UserSingleton.shared.downloadImage()
                    UserSingleton.shared.isLoggedIn = true
                    //PERFORM SEGUE TO Write REVIEWS
                    
                })
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var resetEmail:UITextField?
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset Password", message: "Enter your email address to reset password", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: resetEmail)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Reset", style: .default, handler: { (action) in
            if let text = self.resetEmail?.text{
                if text != ""{
                    Auth.auth().sendPasswordReset(withEmail: text) { (error) in
                        if let error = error{
                            self.displayError(title: "Error", description: error.localizedDescription)
                            return
                        }
                        self.displayError(title: "Email sent", description: "Check your email and follow the link to reset you password")
                    }
                }
                else{
                    self.displayError(title: "Error", description: "Please enter email address")
                }
            }
            else{
                self.displayError(title: "Error", description: "Please enter email address")
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetEmail(textField:UITextField){
        resetEmail = textField
        if let text = self.emailField.text{
            resetEmail?.text = text
        }
        resetEmail?.placeholder = "Email Adress"
    }
    
}
