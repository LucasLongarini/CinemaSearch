//
//  LoadingView.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-24.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

@IBDesignable
class LoadingView: UIView {
    
    @IBInspectable var loadingIcon:UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge){
        didSet{
            updateView()
        }
    }
    @IBInspectable var cornerRadius:CGFloat = 10{
        didSet{
            updateView()
        }
    }
    func updateView(){
        self.layer.cornerRadius = cornerRadius
        loadingIcon.hidesWhenStopped = true
        loadingIcon.stopAnimating()
        self.alpha = 0
        self.addSubview(loadingIcon)
        loadingIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: loadingIcon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingIcon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: loadingIcon, attribute: .height, multiplier: 2.5, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: loadingIcon, attribute: .height, multiplier: 2.5, constant: 0).isActive = true
      
    }
    
    func stopAnimation(){
        self.alpha = 0
        self.loadingIcon.stopAnimating()
    }
    
    func startAnimation(){
        self.alpha = 1
        self.loadingIcon.startAnimating()
    }
    
    
}
