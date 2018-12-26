//
//  StarRatingView.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-23.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

protocol StarViewDelegate {
    func starViewPressed()
}

@IBDesignable
class StarRatingView: UIView {
    private var buttons = [UIButton]()
    private var starIndex:Int = 0
    private var pressed: Bool = false
    
    var delegate: StarViewDelegate?

    var rating:Int {
        get{
            if pressed{
                return starIndex + 1
            }else{
                return 0
            }
        }
    }
    
    @IBInspectable var count:Int = 0{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var spacing:CGFloat = 0{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var userInteraction:Bool = false{
        didSet{
            updateView()
        }
    }
    
    private func updateView(){
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview()}
        for _ in 0..<count{
            let button = UIButton(type: .custom)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(UIImage(named: "Star Outline"), for: .normal)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            button.isUserInteractionEnabled = userInteraction
            buttons.append(button)
        }
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func setStars(rating:Int){
        var n:Int
        if rating > 5 {n = 5}
        else if rating < 1 {n = 1}
        else{n = rating}
        
        for i in 0..<(n){
            buttons[i].setImage(UIImage(named: "Star"), for: .normal)
        }
    }
    
    @objc func buttonPressed(sender:UIButton){
        pressed = true
        if let del = delegate{del.starViewPressed()}
        var fill:Bool = true
        for (i,btn) in buttons.enumerated(){
            if fill{btn.setImage(UIImage(named: "Star"), for: .normal)}
            else{btn.setImage(UIImage(named: "Star Outline"), for: .normal)}
            if btn == sender{
                starIndex = i
                fill = false
            }
        }
    }
}

