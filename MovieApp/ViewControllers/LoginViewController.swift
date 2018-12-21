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

class LoginViewController: UIViewController{
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    
    
    @IBOutlet weak var emailField: LoginField!
    @IBOutlet weak var phoneField: LoginField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
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
    }
    
    @objc func facebookLogin(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let err = error{
                print("FACEBOOK LOGIN FAILED:", err.localizedDescription)
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                if let error = error{
                    print("ERROR SIGNING IN:", error.localizedDescription)
                    return
                }
                print("USER SIGNed iN WITH FCEBOOK")
            })
            
            
        }
    }
    
    
    
}
