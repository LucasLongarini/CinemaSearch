//
//  TrailerViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-09.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import WebKit

enum TrailerType{
    case movie
    case tv
    case season
    case episode
}

class TrailerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
 
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var trailerTableView: UITableView!
    var movieID: Int!
    var tvID: Int!
    var seasonNumber: Int!
    var episodeNumber:Int!
    
    var trailers: [VideoData] = [VideoData]()
    
    let movieHelper = MovieHelper()
    let tvHelper = TvHelper()
    
    var type: TrailerType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        trailerTableView.rowHeight = UITableView.automaticDimension
        trailerTableView.estimatedRowHeight = 250
        loadingView.layer.cornerRadius = 10
        self.trailerTableView.tableFooterView = UIView()
        if let type = self.type{
            switch type{
            case .movie:
                movieHelper.getTrailerIDs(movieID: movieID) { (trailers) in
                    if trailers.count != 0{
                        self.trailers = trailers
                        DispatchQueue.main.async {
                            self.doAnimation()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.displayError(isTrailer: true)
                        }
                    }
                }
            case .tv:
                tvHelper.getTVTrailerIDs(tvID: tvID) { (trailers) in
                    if trailers.count != 0{
                        self.trailers = trailers
                        DispatchQueue.main.async {
                            self.doAnimation()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.displayError(isTrailer: true)
                        }
                    }
                }
            case .season:
                tvHelper.getSeasonTrailerIDs(tvID: tvID, seasonNumber: seasonNumber) { (trailers) in
                    if trailers.count != 0{
                        self.trailers = trailers
                        DispatchQueue.main.async {
                            self.doAnimation()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.displayError(isTrailer: true)
                        }
                    }
                }
            case .episode:
                tvHelper.getEpisodeTrailerIDs(tvID: tvID, seasonNumber: seasonNumber, episodeNumber: episodeNumber) { (trailers) in
                    if trailers.count != 0{
                        self.trailers = trailers
                        DispatchQueue.main.async {
                            self.doAnimation()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.displayError(isTrailer: false)
                        }
                    }
                }
                
            }
        }
    
    }
    
    func displayError(isTrailer: Bool){
        var titleString:String = ""
        if isTrailer{titleString = "No Trailers Available"}
        else{titleString = "No Preview Available"}
        
        let alert = UIAlertController(title: titleString, message: "Check back later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (uialert) in
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trailers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrailerCell", for: indexPath) as! TrailerViewCell
        let trailer = self.trailers[indexPath.row]
        cell.trailerNameLabel.text = trailer.name
        cell.webView.loadVideo(videoID: trailer.key, completion: {
        })
        return cell
    }
    
    func doAnimation(){
        self.loadingView.alpha = 0
        self.loadingIcon.stopAnimating()
        self.trailerTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }

}

extension WKWebView{
    func loadVideo(videoID: String, completion: @escaping ()->()){
        let urlString = "https://www.youtube.com/embed/\(videoID)"
        if let url = URL(string: urlString){
            DispatchQueue.main.async {
                self.load(URLRequest(url: url))
                completion()
            }
        }
    }
}
