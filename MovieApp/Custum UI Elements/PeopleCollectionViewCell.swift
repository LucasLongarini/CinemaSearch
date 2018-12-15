//
//  PeopleCollectionViewCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-30.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class PeopleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var actorNameLabel: UILabel!
    @IBOutlet weak var characterNameLabel: UILabel!
    
    override func awakeFromNib() {
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        shadowView.layer.cornerRadius = shadowView.frame.height / 2
        shadowView.addCircleShadow()
    }
}
