//
//  InfoCellTableViewCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-11-28.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

enum MediaType{
    case movie
    case tv
}

protocol InfoCellDelegate {
    func cellTapped(index:Int, mediaType:MediaType)
}

class InfoCellTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    var mediaType:MediaType?
    var cellIndex:Int = -1
    var delegate: InfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addDropShadow()
        picture.clipsToBounds = true
        let gester = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(gester)
    }
    
    @objc func tapped(){
        guard let delegate = self.delegate else{return}
        guard let mediaType = self.mediaType else {return}
        if cellIndex != -1{
            delegate.cellTapped(index: cellIndex, mediaType: mediaType)
        }
    }

}
