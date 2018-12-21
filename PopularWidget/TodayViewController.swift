//
//  TodayViewController.swift
//  PopularWidget
//
//  Created by Lucas Longarini on 2018-12-19.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firstShadow: UIView!
    @IBOutlet weak var secondShadow: UIView!
    @IBOutlet weak var thirdShadow: UIView!
    @IBOutlet weak var expandLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:190)
        
        firstImage.clipsToBounds = true
        secondImage.clipsToBounds = true
        thirdImage.clipsToBounds = true
        firstShadow.addDropShadow()
        secondShadow.addDropShadow()
        thirdShadow.addDropShadow()
        expandLabel.alpha = 0

        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))

        firstImage.addGestureRecognizer(gesture1)
        firstImage.isUserInteractionEnabled = true
        secondImage.addGestureRecognizer(gesture2)
        secondImage.isUserInteractionEnabled = true
        thirdImage.addGestureRecognizer(gesture3)
        thirdImage.isUserInteractionEnabled = true
        
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    
    switch (activeDisplayMode){
    case .expanded:
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:190)
        UIView.animate(withDuration: 0.4) {
            self.expandLabel.alpha = 0
            self.firstLabel.alpha = 1
            self.secondLabel.alpha = 1
            self.thirdLabel.alpha = 1
            self.firstImage.alpha = 1
            self.secondImage.alpha = 1
            self.thirdImage.alpha = 1
            self.firstShadow.alpha = 1
            self.secondShadow.alpha = 1
            self.thirdShadow.alpha = 1
        }
    case .compact:
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:110)
        UIView.animate(withDuration: 0.4) {
            self.expandLabel.alpha = 1
            self.firstLabel.alpha = 0
            self.secondLabel.alpha = 0
            self.thirdLabel.alpha = 0
            self.firstImage.alpha = 0
            self.secondImage.alpha = 0
            self.thirdImage.alpha = 0
            self.firstShadow.alpha = 0
            self.secondShadow.alpha = 0
            self.thirdShadow.alpha = 0
        }
    }
    
    }
    
    func updateView(movies:[Movie]){
        firstLabel.text = movies[0].title
        secondLabel.text = movies[1].title
        thirdLabel.text = movies[2].title
        firstImage.loadImageFromUrl(urlString: movies[0].posterPath)
        secondImage.loadImageFromUrl(urlString: movies[1].posterPath)
        thirdImage.loadImageFromUrl(urlString: movies[2].posterPath)
    }
    
    func checkIfNewData(movies:[Movie])->Bool{
        if self.firstLabel.text == movies[0].title && self.secondLabel.text == movies[1].title && self.thirdLabel.text == movies[2].title{
            return false
        }
        return true
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=5ef3636bee9e119d63d5c4c91aefc53d&language=en-US&page=1&region=US"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                completionHandler(.failed)
                return
            }
            
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonMovieData.self, from: data)
                if self.checkIfNewData(movies: jsonData.results){
                    DispatchQueue.main.async {
                        self.updateView(movies: jsonData.results)
                    }
                    completionHandler(.newData)
                }
                else{
                    completionHandler(.noData)
                }
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
        
    }
    
    @objc func imageTapped(){
        let url = URL(string: "CinemaSearch://")
        self.extensionContext?.open(url!, completionHandler: { (success) in
            if !success{
                print("error opening url")
            }
        })

    }
    
}

struct JsonMovieData: Decodable {
    var page: Int = 0
    var results: [Movie] = [Movie]()
}

extension UIView{
    func addDropShadow(){
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false;
        clipsToBounds = false;
    }
}

extension UIImageView{
    func loadImageFromUrl(urlString:String?){
        guard let path = urlString else{return}
        let url = URL(string: "https://image.tmdb.org/t/p/w154\(path)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    self.image = downloadedImage
                }
            }
            
        }.resume()
    }
    
}
