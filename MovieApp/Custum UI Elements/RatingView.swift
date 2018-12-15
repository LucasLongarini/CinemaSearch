//
//  RatingView.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-30.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

@IBDesignable
class RatingView: UIView {

    @IBInspectable
    var color: UIColor = UIColor.black{
        didSet{
            ratingAmount.backgroundColor = color
            updateView()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.black{
        didSet{
            layer.borderColor = borderColor.cgColor
            updateView()
        }
    }
    
    @IBInspectable
    var borderThicknes: CGFloat = 1{
        didSet{
            layer.borderWidth = borderThicknes
            updateView()
        }
    }
    
    var ratingAmount: UIView = UIView()

    override func draw(_ rect: CGRect) {

    }
    
    func updateView(){
        subviews.forEach { $0.removeFromSuperview()}
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.height / 2
        ratingAmount.backgroundColor = color
        ratingAmount.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
        ratingAmount.layer.cornerRadius = ratingAmount.frame.height / 2
        self.addSubview(ratingAmount)
    }
    
    func animate(withDuration: TimeInterval, percentAmount: CGFloat){
        UIView.animate(withDuration: withDuration, delay: 0, options: .curveEaseOut, animations: {
            self.ratingAmount.frame.size.width = self.frame.width * (percentAmount)
            
        }, completion: nil)
    }

}
