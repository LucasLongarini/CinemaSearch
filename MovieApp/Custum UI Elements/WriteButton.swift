//
//  WriteButton.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-23.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class WriteButton: UIButton {
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }

}
