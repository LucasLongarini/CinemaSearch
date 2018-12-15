//
//  WatchListCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-27.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class WatchListCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var labelFrame: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    var cellHeight: CGFloat!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellHeight = backgroundImage.frame.height + 16
        shadowView.addDropShadow()
        backgroundImage.layer.cornerRadius = 5
        backgroundImage.clipsToBounds = true
        shadowView.layer.cornerRadius = 5
        labelFrame.clipsToBounds = true
        labelFrame.layer.cornerRadius = 5
        //.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }


}
