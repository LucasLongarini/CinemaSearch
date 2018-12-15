//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-27.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    var shadowView: UIView!
    
    override func awakeFromNib() {
        shadowView = UIView()
        posterImage.clipsToBounds = true
        
        shadowView.backgroundColor = UIColor.white
        self.insertSubview(shadowView, at:0)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.trailingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 0).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: posterImage.leadingAnchor, constant: 0).isActive = true
        shadowView.topAnchor.constraint(equalTo: posterImage.topAnchor, constant: 0).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 0).isActive = true
        
        shadowView.addDropShadow()
        
        movieTitle.sizeToFit()
    }
}
