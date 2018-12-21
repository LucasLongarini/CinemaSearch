//
//  LoginField.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-20.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

@IBDesignable
class LoginField: UITextField {
    
    @IBInspectable var leftPadding: CGFloat = 0{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var leftImage: UIImage?{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 0{
        didSet{
            updateView()
        }
    }

    var underlineView:UIView!
    
    func updateView(){
        creaetLine()
        
        if let image = leftImage{
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: 20, height: 20))
            imageView.tintColor = tintColor
            imageView.image = image
            
            var width = leftPadding + 20
            if borderStyle == UITextField.BorderStyle.none || borderStyle == UITextField.BorderStyle.line{
                width = width + 10
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
            view.addSubview(imageView)
            leftView = view
        }else{
            leftViewMode = .always
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: self.frame.size.height))
            self.leftView = paddingView
        }
    }
    
    fileprivate func creaetLine() {
        underlineView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
        underlineView.backgroundColor = UIColor.lightGray
        self.addSubview(underlineView)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        underlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        NSLayoutConstraint(item: underlineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: lineWidth).isActive = true
    }

}
