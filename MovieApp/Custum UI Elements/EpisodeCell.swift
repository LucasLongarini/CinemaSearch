//
//  EpisodeCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-12.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet weak var episodePicture: UIImageView!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDueDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        episodePicture.layer.cornerRadius = episodePicture.frame.height / 2
        episodePicture.clipsToBounds = true
        shadowView.layer.cornerRadius = shadowView.frame.height / 2
        shadowView.addCircleShadow()
        
    }


}

