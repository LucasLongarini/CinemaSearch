//
//  SeasonViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-12.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class SeasonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var airOnLabel: UILabel!
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seasonPicture: UIImageView!
    var seasonImage: UIImage!
    @IBOutlet weak var viewTrailerButton: UIButton!
    @IBOutlet weak var seasonDescription: UILabel!
    @IBOutlet weak var seasonTitle: UILabel!
    
    @IBOutlet weak var episodeCount: UILabel!
    @IBOutlet weak var airDate: UILabel!
    
    @IBOutlet weak var episodeCountTop: NSLayoutConstraint!
    @IBOutlet weak var castCollection: UICollectionView!
    
    let tvHelper = TvHelper()
    let personHelper = PersonHelper()
    
    var episodes: [Episode]?
    var cast: [Person]?
    var tvID: Int!
    var season: TvSeason!
    var seasonTopTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seasonPicture.clipsToBounds = true
        shadowView.addDropShadow()
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        loadingView.layer.cornerRadius = 10
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),style: .plain,target: navigationController,action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.tableFooterView = UIView()
        setupSeason()
        getEpisodes()
        setupAnimation()
        
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
    }
    
    func setupSeason(){
        if let s = self.season{
            seasonTitle.text = s.name
            if let title = self.seasonTopTitle{
                self.navigationItem.title = title
            }else{self.navigationItem.title = s.name}
            if let date = s.airDate{
                if date.isFutureDate(){airOnLabel.text = "Airs On"}
                else{airOnLabel.text = "Aired On"}
                airDate.text = date.changeDateFormating()
            }else{airDate.text = "Not Available"}
            if s.overview != ""{
                seasonDescription.text = s.overview
            }else{
                seasonDescription.text = "No description available"
            }
            if let image = seasonImage{
                seasonPicture.image = image
            }
            if s.episodeCount == 1{
                episodeCount.text = "\(s.episodeCount) Episode"
            }else{episodeCount.text = "\(s.episodeCount) Episodes"}
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 118, height: 160)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15 - 5, bottom: 0, right: 15 - 5)
        castCollection.collectionViewLayout = layout
    }
    
    func getEpisodes(){
        tvHelper.getEpisodes(tvID: self.tvID, seasonNumber: self.season.seasonNumber) { (episodes) in
            if episodes != nil{
                self.episodes = episodes
                self.checkDownload()
            }else{
                self.episodes = nil
                self.checkDownload()
            }
        }
        personHelper.getPeopleForSeason(tvID: self.tvID, seasonNumber: self.season.seasonNumber) { (people) in
            self.cast = people
            DispatchQueue.main.async {
                self.castCollection.reloadData()
            }
            self.checkDownload()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let eps = self.episodes{
            return eps.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell") as! EpisodeCell
        if let episodes = self.episodes{
            cell.episodePicture.image = UIImage(named: "Episode Place Holder")
            let episode = episodes[indexPath.row]
            cell.episodeName.text = "\(episode.episodeNumber) \(episode.name)"
            if episode.overview == ""{
                cell.episodeDueDate.text = "No description"
            }else{cell.episodeDueDate.text = episode.overview}
            if let imageUrl = episode.stillPath{
                cell.episodePicture.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w300\(imageUrl)")
            }
            return cell
        }else{
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(120)
    }

    var episodeToSend: Episode?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.episodeToSend = self.episodes?[indexPath.row]
        performSegue(withIdentifier: "SeasonToEpisode", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SeasonToEpisode"{
            if let dest = segue.destination as? TVEpisodeViewController{
                dest.tvEpisode = episodeToSend
                dest.seasonNumber = self.season.seasonNumber
                dest.tvID = self.tvID
            }
        }
        else if segue.identifier == "SeasonToTrailer"{
            if let dest = segue.destination as? TrailerViewController{
                dest.tvID = self.tvID
                dest.seasonNumber = self.season.seasonNumber
                dest.type = .season
            }
        }
        else if segue.identifier == "SeasonToPerson"{
            if let dest = segue.destination as? PersonViewController{
                dest.person = self.personToSend
                dest.personImage = self.imageToSend
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let people = self.cast{
            return people.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! PeopleCollectionViewCell
        cell.profilePicture.image = #imageLiteral(resourceName: "Person Placeholder Image")
        if let cast = self.cast{
            let person = cast[indexPath.row]
            cell.actorNameLabel.text = person.name
            cell.characterNameLabel.text = person.character
            if let imageUrl = person.profilePath{
                cell.profilePicture.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
            }
        }
        return cell
    }
    
    var personToSend: Person?
    var imageToSend:UIImage?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.castCollection{
            if let cast = self.cast{
                personToSend = cast[indexPath.row]
                let cell = collectionView.cellForItem(at: indexPath) as! PeopleCollectionViewCell
                imageToSend = cell.profilePicture.image
                performSegue(withIdentifier: "SeasonToPerson", sender: self)
            }
        }
    }
    
    //animation constriants
    @IBOutlet weak var trailerConstraint: NSLayoutConstraint!
    @IBOutlet weak var seasonCastLabel: UILabel!
    @IBOutlet weak var airedOnConstraint: NSLayoutConstraint!
    @IBOutlet weak var airedOnLabelContraint: NSLayoutConstraint!
    @IBOutlet weak var seasonPictureConstraint: NSLayoutConstraint!
    
    func setupAnimation(){
        seasonPictureConstraint.constant = -seasonPicture.frame.width
        self.airedOnConstraint.constant = -self.view.frame.width/2
        self.airedOnLabelContraint.constant =  -self.view.frame.width/2
        self.trailerConstraint.constant = -self.viewTrailerButton.frame.width
        view.layoutIfNeeded()
        tableView.alpha = 0
    }
    
    func doAnimation(){
        if self.cast?.count ?? 0 == 0{
            self.episodeCountTop.isActive = false
            self.episodeCount.topAnchor.constraint(equalTo: self.airDate.bottomAnchor, constant: 20).isActive = true
            seasonCastLabel.alpha = 0
            self.view.layoutIfNeeded()
            tableView.tableHeaderView?.frame.size.height = self.episodeCount.frame.maxY + 4
            self.view.layoutIfNeeded()
        }
        else{
            tableView.tableHeaderView?.frame.size.height = self.episodeCount.frame.maxY + 4
            self.view.layoutIfNeeded()
        }
        loadingView.alpha = 0
        activityIcon.stopAnimating()
        self.seasonPictureConstraint.constant = 15
        self.airedOnConstraint.constant = 15
        self.airedOnLabelContraint.constant = 15
        self.trailerConstraint.constant = 15
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tableView.alpha = 1
        }, completion: nil)
        self.tableView.reloadData()
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
