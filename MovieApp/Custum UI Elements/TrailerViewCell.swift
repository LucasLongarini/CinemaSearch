//
//  TrailerViewCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-09.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import WebKit
class TrailerViewCell: UITableViewCell, WKNavigationDelegate {
    
    var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var trailerNameLabel: UILabel!
    var webView:WKWebView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.allowsInlineMediaPlayback = false
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), configuration: webConfiguration)
        self.contentView.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12).isActive = true
        webView.topAnchor.constraint(equalTo: self.trailerNameLabel.bottomAnchor, constant: 8).isActive = true
        NSLayoutConstraint(item: self.webView, attribute: .height, relatedBy: .equal, toItem: self.webView, attribute: .width, multiplier: (315/560), constant: 0).isActive = true
        
        webView.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        webView.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .vertical)
        webView.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
        webView.setContentCompressionResistancePriority(UILayoutPriority(750), for: .vertical)

        activityIcon = UIActivityIndicatorView(style: .gray)
        activityIcon.startAnimating()
        activityIcon.hidesWhenStopped = true
        self.contentView.addSubview(activityIcon)
        activityIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: activityIcon, attribute: .centerX, relatedBy: .equal, toItem: self.webView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIcon, attribute: .centerY, relatedBy: .equal, toItem: self.webView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        self.webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIcon.stopAnimating()
    }

    override func prepareForReuse() {
        self.activityIcon.startAnimating()
    }

}
