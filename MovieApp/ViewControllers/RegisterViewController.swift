//
//  RegisterViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-21.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var changeProfilePicture: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
        
        changeProfilePicture.layer.cornerRadius = changeProfilePicture.frame.height/2
        
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        Auth.auth().createUser(withEmail: "test@email.com", password: "pass123") { (authResult, error) in
            if let err = error{
                print(err)
                return
            }
            guard let user = authResult?.user else {return}
            print("User succesfully registered")
        }
    }
}
