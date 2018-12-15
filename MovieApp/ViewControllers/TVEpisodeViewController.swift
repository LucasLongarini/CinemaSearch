//
//  TVEpisodeViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-20.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class TVEpisodeViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0

    @IBOutlet weak var noCastLabel: UILabel!
    //@IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var bottomContentViewContraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    var backgroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var EpisodeName: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var guestStarsLabel: UILabel!
    @IBOutlet weak var airedOn: UILabel!
    @IBOutlet weak var airedOnLabel: UILabel!
    @IBOutlet weak var viewPreviewButton: UIButton!
    @IBOutlet weak var castCollection: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    
    var tvEpisode: Episode!
    var seasonNumber: Int!
    var tvID: Int!

    var cast: [Person]?
    
    let personHelper = PersonHelper()
    
    var noCast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width*(9/16)))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = UIImage(named: "background Image placeholder")
        backgroundImage.clipsToBounds = true
        self.view.insertSubview(backgroundImage, at: 0)
        
        self.scrollView.delegate = self
        self.castCollection.delegate = self
        self.castCollection.dataSource = self
        loadingView.layer.cornerRadius = 10
        initalizeView()
        setupEpisode()
        setupAnimaion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.isBeingPresented || self.isMovingToParent {
            self.semaphore.wait()
            self.totalDownloaded += 1
            if self.totalDownloaded == 3{
                self.semaphore.signal()
                self.doAnimation()
            }else{self.semaphore.signal()}
        }
        
        let diff = self.scrollView.frame.height - (contentView.frame.height + backgroundImage.frame.height)
        if diff >= 0{
            bottomContentViewContraint.constant += diff + 1
            self.view.layoutIfNeeded()
        }
    }
    
    func setupEpisode(){
        if let episode = self.tvEpisode{
            EpisodeName.text = episode.name
            if episode.voteAverage <= 0{
                ratingLabel.text = "Not Rated"
            }else{
                ratingLabel.text = "\(Int(episode.voteAverage*10))%"
            }
            if let air = episode.airDate{
                if air.isFutureDate(){airedOnLabel.text = "Airs On"}
                else{airedOnLabel.text = "Aired On"}
                airedOn.text = air.changeDateFormating()
            }else{
                airedOn.text = "Not Available"
            }
            if episode.overview == ""{
                overview.text = "Not Available"
            }else{
                overview.text = episode.overview
            }
            self.navigationItem.title = episode.name
            
            if episode.stillPath != "" && episode.stillPath != nil{
                downloadBackground(urlString: "https://image.tmdb.org/t/p/original\(episode.stillPath!)")
            }
            else{
                self.checkDownload()
            }
        }
        
        personHelper.getPeopleForEpisode(tvID: self.tvID, seasonNumber: self.seasonNumber, episodeNumber: self.tvEpisode.episodeNumber) { (people) in
            self.cast = people
            if people?.count ?? 0 == 0{
                self.noCast = true
            }
            DispatchQueue.main.async {
                self.castCollection.reloadData()
            }
            self.checkDownload()
        }
        
    }
    
    func downloadBackground(urlString: String){
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                self.checkDownload()
                return
            }
            DispatchQueue.main.sync{
                if let downloadedImage = UIImage(data: data!){
                    self.backgroundImage.image = downloadedImage
                }
            }
            self.checkDownload()
        }.resume()
        
    }
    
    func initalizeView(){
        scrollView.contentInset = UIEdgeInsets(top: self.backgroundImage.frame.height, left: 0, bottom: 0, right: 0)
        self.backgroundImage.clipsToBounds = true
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),style: .plain,target: navigationController,action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 118, height: 160)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15 - 5, bottom: 0, right: 15 - 5)
        castCollection.collectionViewLayout = layout
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == self.scrollView){
            let offsetY = -scrollView.contentOffset.y
            let height = max(0, offsetY)
            backgroundImage.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let cast = self.cast{
            return cast.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = castCollection.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! PeopleCollectionViewCell
        cell.profilePicture.image = #imageLiteral(resourceName: "Person Placeholder Image")
        if let cast = self.cast{
            let person = cast[indexPath.row]
            cell.actorNameLabel.text = person.name
            cell.characterNameLabel.text = person.character
            if let imageUrl = person.profilePath{
                cell.profilePicture.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
            }
            return cell
        }else{
            return cell
        }
    }

    var personToSend:Person?
    var imageToSend: UIImage?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.castCollection{
            if let cast = self.cast{
                personToSend = cast[indexPath.row]
                let cell = collectionView.cellForItem(at: indexPath) as! PeopleCollectionViewCell
                imageToSend = cell.profilePicture.image
                performSegue(withIdentifier: "EpisodeToPerson", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EpisodeToTrailer"{
            if let dest = segue.destination as? TrailerViewController{
                dest.tvID = tvID
                dest.seasonNumber = seasonNumber
                dest.episodeNumber = tvEpisode.episodeNumber
                dest.type = .episode
            }
        }
        else if segue.identifier == "EpisodeToPerson"{
            if let dest = segue.destination as? PersonViewController{
                dest.person = self.personToSend
                dest.personImage = self.imageToSend
            }
        }
    }
    
    //constraints
    @IBOutlet weak var airedLabelCst: NSLayoutConstraint!
    @IBOutlet weak var airedCst: NSLayoutConstraint!
    @IBOutlet weak var overviewLabelCst: NSLayoutConstraint!
    @IBOutlet weak var overviewCst: NSLayoutConstraint!
    
    
    func setupAnimaion(){
        let con = -view.frame.width
        self.backgroundImage.alpha = 0
        self.EpisodeName.alpha = 0
        self.ratingView.alpha = 0
        self.ratingLabel.alpha = 0
        self.viewPreviewButton.alpha = 0
        self.castCollection.alpha = 0
        self.guestStarsLabel.alpha = 0
        self.noCastLabel.alpha = 0
        airedLabelCst.constant = con
        airedCst.constant = con
        overviewCst.constant = con
        overviewLabelCst.constant = con
        self.view.layoutIfNeeded()
    }
    
    func doAnimation(){
        loadingView.alpha = 0
        activityIcon.stopAnimating()
        if tvEpisode.voteAverage > 0{
            let amount = CGFloat(tvEpisode.voteAverage / 10)
            ratingView.animate(withDuration: 0.6, percentAmount: amount)
        }
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundImage.alpha = 1
            self.EpisodeName.alpha = 1
            self.ratingView.alpha = 1
            self.ratingLabel.alpha = 1
            self.viewPreviewButton.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.airedCst.constant = 15
            self.airedLabelCst.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.overviewCst.constant = 15
            self.overviewLabelCst.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut, animations: {
            if self.noCast{self.noCastLabel.alpha = 1}
            else{self.castCollection.alpha = 1}
            self.guestStarsLabel.alpha = 1
        }, completion: nil)

    }
    
    func checkDownload(){
        self.semaphore.wait()
        self.totalDownloaded += 1
        if self.totalDownloaded == 3{
            self.semaphore.signal()
            DispatchQueue.main.async {
                self.doAnimation()
            }
        }else{self.semaphore.signal()}
    }

    
}
