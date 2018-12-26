//
//  ReviewCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-22.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

protocol ReviewCellDelegate {
    func showMorePressed()
}

class ReviewCell: UITableViewCell {
    
    var delegate:ReviewCellDelegate?
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingView: StarRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.layer.borderWidth = 1
        profilePicture.clipsToBounds = true

        self.profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
    }
    
    func setDesctiption(description:String){
        descriptionLabel.text = description
        self.layoutIfNeeded()
        if !descriptionLabel.isTruncated{
            seeMoreButton.isHidden = true
        }else{
            seeMoreButton.isHidden = false
        }
    }
    
    func setReview(value:Int){
        ratingView.setStars(rating: value)
    }
    
    @IBAction func seeMoreButtonPressed(_ sender: Any) {
        guard let delegate = self.delegate else{return}
        
        if let button = sender as? UIButton{
            if button.titleLabel?.text == "See more"{
                button.setTitle("See less", for: .normal)
                descriptionLabel.numberOfLines = 0
                delegate.showMorePressed()
            }
            else if button.titleLabel?.text == "See less"{
                button.setTitle("See more", for: .normal)
                descriptionLabel.numberOfLines = 6
                delegate.showMorePressed()
            }
        }
    }
}
