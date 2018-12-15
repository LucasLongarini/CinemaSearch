//
//  TVViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class TVViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0
    var downloadedRequired = 5
    
    var watchListBackgroundImage: UIImage!
    @IBOutlet weak var addToWatchlistButton: UIBarButtonItem!
    var managedObjectContext:NSManagedObjectContext!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var airOnLabel: UILabel!
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    let personHelper = PersonHelper()
    let tvHelper = TvHelper()
    var tv: Tv!
    var posterUIImage: UIImage!
    var seasons: [TvSeason]!
    var people: [Person]!
    var recommended: [Tv]!
    
    var watchListTvID:Int!
    
    @IBOutlet weak var noCaseLabel: UILabel!
    @IBOutlet weak var noSeasonLabel: UILabel!
    @IBOutlet weak var scrollViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var viewTrailerButton: UIButton!
    @IBOutlet weak var posterImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var seasonsCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var episodesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var posterImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var posterImage: UIImageView!
    var backgroundImage: UIImageView!
    var watchlistTitle:String?
    
    var noCast:Bool = false
    var noSeason:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width*(9/16)))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = UIImage(named: "background Image placeholder")
        backgroundImage.clipsToBounds = true
        self.view.insertSubview(backgroundImage, at: 0)
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        initalizeView()
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),style: .plain,target: navigationController,action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        setUpAnimation()
        if let tv = self.tv{
            downloadBackroundImage()
            setUpScrollViews(id: tv.id)
            setTvInfo()
            checkIfInWatchlist(tvID: tv.id)
        }else if self.watchListTvID != nil{
            self.downloadedRequired = 6
            setUpScrollViews(id: watchListTvID)
            setTvInfoFromWatchlist()
            self.inWatchList = true;
        }
        
        if inWatchList{self.addToWatchlistButton.image = UIImage(named: "addPressed")}
        else {self.addToWatchlistButton.image = UIImage(named: "addUnpressed")}
        loadingView.layer.cornerRadius = 10
        noSeasonLabel.alpha = 0
        noCaseLabel.alpha = 0
    }
    
    func setUpScrollViews(id: Int){
        personHelper.getPeopleForTv(tvId: id) { (people) in
            if people.count <= 0{
                self.noCast = true
            }
            else{
                self.people = people
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            }
            self.checkDownload()
        }
        tvHelper.getRecommenedTv(tvID: id) { (shows) in
            if shows.count <= 0{
                DispatchQueue.main.async {
                    self.scrollViewBottomLayout.constant = -self.recommendedCollectionView.frame.height - self.recommendedLabel.frame.height
                    self.recommendedLabel.isHidden = true
                }
            }
            else{
                self.recommended = shows
                DispatchQueue.main.async {
                    self.recommendedCollectionView.reloadData()
                }
            }
            self.checkDownload()
        }
    }
    
    func setTvInfoFromWatchlist(){
        
        if let title = self.watchlistTitle{self.navigationItem.title = title}

        tvHelper.downloadTvDetails(tvID: watchListTvID) { (otherTvData) in
            if otherTvData.seasons.count <= 0{
                DispatchQueue.main.async {
                    self.noSeason = true
                }
            }
            self.seasons = otherTvData.seasons
            DispatchQueue.main.async {
                self.episodesLabel.text = "\(otherTvData.numberOfEpisodes) Episodes"
                self.seasonsCollectionView.reloadData()
            }
            self.checkDownload()
        }
        self.tv = Tv()
        self.tv.id = self.watchListTvID
        tvHelper.getAllTvDetails(tvID: watchListTvID) { (tv) in

            self.tv.voteAverage = tv.voteAverage
            DispatchQueue.main.async {
                self.titleLabel.text = tv.name
                if tv.overview == ""{
                    self.plotLabel.text = "No overview available"
                }else{self.plotLabel.text = tv.overview}
                if tv.firstAirDate != ""{
                    if tv.firstAirDate.isFutureDate(){self.airOnLabel.text = "Airs On"}
                    else{self.airOnLabel.text = "Aired On"}
                    self.releaseDate.text = tv.firstAirDate.changeDateFormating()
                }else{self.releaseDate.text = "Not Available"}
                self.backgroundImage.image = self.watchListBackgroundImage
                if tv.voteAverage <= 0{
                    self.ratingLabel.text = "Not Rated"
                }else{
                    self.ratingLabel.text = "\(Int(tv.voteAverage))%"
                }
                self.downloadPosterImage(posterPath: tv.posterPath)
            }
            self.checkDownload()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.isBeingPresented || self.isMovingToParent {
            DispatchQueue.main.async {
                self.checkDownload()
            }
        }
    }
    
    func downloadPosterImage(posterPath:String?){
        if let path = posterPath{
            let urlString = "https://image.tmdb.org/t/p/w154\(path)"
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    self.checkDownload()
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        ImageCache.shared.imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.posterImage.image = downloadedImage
                    }
                }
                self.checkDownload()
            }.resume()
        }else{
            self.checkDownload()
        }
    }
    
    func setTvInfo(){
        if let tv = self.tv{
            tvHelper.downloadTvDetails(tvID: tv.id) { (otherTvData) in
                if otherTvData.seasons.count <= 0{
                    self.noSeason = true
                }
                self.seasons = otherTvData.seasons
                DispatchQueue.main.async {
                    self.episodesLabel.text = "\(otherTvData.numberOfEpisodes) Episodes"
                    self.seasonsCollectionView.reloadData()
                }
                self.checkDownload()
            }
            self.titleLabel.text = tv.name
            self.navigationItem.title = tv.name
            if tv.overview == ""{
                self.plotLabel.text = "No overview available"
            }else{self.plotLabel.text = tv.overview}
            if tv.firstAirDate != ""{
                if tv.firstAirDate.isFutureDate(){airOnLabel.text = "Airs On"}
                else{airOnLabel.text = "Aired On"}
                self.releaseDate.text = tv.firstAirDate.changeDateFormating()
            }else{self.releaseDate.text = "Not Available"}
        }
        if let image = posterUIImage{
            self.posterImage.image = image
        }
        if tv.voteAverage <= 0{
            ratingLabel.text = "Not Rated"
        }else{
            ratingLabel.text = "\(Int(tv.voteAverage*10))%"
        }
        
    }
    func downloadBackroundImage(){
        if let backdropUrl = tv.backdropPath{
            let urlString = "https://image.tmdb.org/t/p/w780\(backdropUrl)"
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    self.checkDownload()
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        ImageCache.shared.imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.backgroundImage.image = downloadedImage
                    }
                }
                self.checkDownload()
            }.resume()
        }else{
            self.checkDownload()
        }
    }
    
    func initalizeView(){
        posterImageTopConstraint.constant = -(posterImage.frame.height * (1/3))
        posterImage.clipsToBounds = true
        shadowView.addDropShadow()
        scrollView.contentInset = UIEdgeInsets(top: self.backgroundImage.frame.height, left: 0, bottom: 0, right: 0)
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: 110, height: 190)
        layout2.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout2.minimumLineSpacing = 8
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 15 - 4, bottom: 0, right: 15 - 4)
        seasonsCollectionView.collectionViewLayout = layout2
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 118, height: 160)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15 - 5, bottom: 0, right: 15 - 5)
        castCollectionView.collectionViewLayout = layout
        
        let layout3 = UICollectionViewFlowLayout()
        layout3.itemSize = CGSize(width: 110, height: 190)
        layout3.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout3.minimumLineSpacing = 8
        layout3.sectionInset = UIEdgeInsets(top: 0, left: 15 - 4, bottom: 0, right: 15 - 4)
        recommendedCollectionView.collectionViewLayout = layout3
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.scrollView){
            let offsetY = -scrollView.contentOffset.y
            let height = max(0, offsetY)
            backgroundImage.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.seasonsCollectionView{
            if let seasons = self.seasons{
                return seasons.count
            }else{return 0}
        }
        if collectionView == self.castCollectionView{
            if let people = self.people{
                return people.count
            }else{return 0}
        }
        if collectionView == self.recommendedCollectionView{
            if let recommended = self.recommended{
                return recommended.count
            }else{return 0}
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.seasonsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
            cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
            if let seasons = self.seasons{
                let season = seasons[indexPath.row]
                cell.movieTitle.text = season.name
                if let imageUrl = season.posterPath{
                    cell.posterImage.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w154\(imageUrl)")
                }
            }
            return cell
       }
        else if collectionView == self.castCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! PeopleCollectionViewCell
            cell.profilePicture.image = #imageLiteral(resourceName: "Person Placeholder Image")
            if let people = self.people{
                let person = people[indexPath.row]
                cell.actorNameLabel.text = person.name
                cell.characterNameLabel.text = person.character
                if let imageUrl = person.profilePath{
                    cell.profilePicture.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
                }
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
            cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
            if let recommended = self.recommended{
                let recomend = recommended[indexPath.row]
                cell.movieTitle.text = recomend.name
                if let imageUrl = recomend.posterPath{
                    cell.posterImage.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w154\(imageUrl)")
                }
            }
            return cell
        }
    }
    
    var seasonToSend: TvSeason!
    var imageToSend: UIImage!
    var personToSend: Person?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.seasonsCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            imageToSend = cell.posterImage.image
            seasonToSend = seasons[indexPath.row]
            performSegue(withIdentifier: "TvToSeason", sender: self)
        }
        else if collectionView == self.recommendedCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            let imageToSend = cell.posterImage.image
            let tvToSend = recommended[indexPath.row]
            if let dest = self.storyboard?.instantiateViewController(withIdentifier: "TvController") as? TVViewController{
                dest.posterUIImage = imageToSend
                dest.tv = tvToSend
                self.navigationController?.pushViewController(dest, animated: true)
            }
        }
        else if collectionView == self.castCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! PeopleCollectionViewCell
            imageToSend = cell.profilePicture.image
            personToSend = self.people[indexPath.row]
            performSegue(withIdentifier: "TvToPeople", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TvToSeason"{
            if let dest = segue.destination as? SeasonViewController{
                dest.season = seasonToSend
                dest.seasonImage = imageToSend
                dest.tvID = self.tv.id
                dest.seasonTopTitle = self.tv.name
            }
        }
        else if segue.identifier == "TVToTrailer"{
            if let dest = segue.destination as? TrailerViewController{
                dest.tvID = self.tv.id
                dest.type = .tv
            }
        }
        else if segue.identifier == "TvToPeople"{
            if let dest = segue.destination as? PersonViewController{
                dest.person = personToSend
                dest.personImage = imageToSend
            }
        }
    }
    
    //constraints
    @IBOutlet weak var airDateLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var airDateConstraint: NSLayoutConstraint!
    @IBOutlet weak var overViewLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var overviewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seasonsLabel: UILabel!
    @IBOutlet weak var mainCastLabel: UILabel!
    @IBOutlet weak var recommendedLabel: UILabel!
    func setUpAnimation(){
        self.backgroundImage.alpha = 0
        self.episodesLabel.alpha = 0
        self.titleLabel.alpha = 0
        self.posterImageConstraint.constant = -self.posterImage.frame.width - 4
        self.ratingLabel.alpha = 0
        self.ratingView.alpha = 0
        self.viewTrailerButton.alpha = 0
        self.airDateLabelConstraint.constant = -self.view.frame.width
        self.airDateConstraint.constant = -self.view.frame.width
        self.overviewConstraint.constant = -self.view.frame.width
        self.overViewLabelConstraint.constant = -self.view.frame.width
        self.seasonsLabel.alpha = 0
        self.mainCastLabel.alpha = 0
        self.recommendedLabel.alpha = 0
        self.seasonsCollectionView.alpha = 0
        self.castCollectionView.alpha = 0
        self.recommendedCollectionView.alpha = 0
        self.addToWatchlistButton.isEnabled = false
    }
    
    func doAnimation(){
        self.addToWatchlistButton.isEnabled = true
        loadingView.alpha = 0
        activityIcon.stopAnimating()
        if tv.voteAverage > 0{
            let amount = CGFloat(tv.voteAverage / 10)
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                self.ratingView.ratingAmount.frame.size.width = self.ratingView.frame.width * (amount)
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundImage.alpha = 1
            self.episodesLabel.alpha = 1
            self.titleLabel.alpha = 1
            self.ratingLabel.alpha = 1
            self.ratingView.alpha = 1
            self.viewTrailerButton.alpha = 1
            self.posterImageConstraint.constant = 15
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.airDateLabelConstraint.constant = 15
            self.airDateConstraint.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.35, options: .curveEaseOut, animations: {
            self.overviewConstraint.constant = 15
            self.overViewLabelConstraint.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if noCast{
            noCaseLabel.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: {
                self.noCaseLabel.alpha = 1
            },completion: nil)
        }
        if noSeason{
            noSeasonLabel.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: {
                self.noSeasonLabel.alpha = 1
            },completion: nil)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: {
            self.seasonsLabel.alpha = 1
            self.mainCastLabel.alpha = 1
            if !self.recommendedLabel.isHidden {self.recommendedLabel.alpha = 1}
            self.seasonsCollectionView.alpha = 1
            self.castCollectionView.alpha = 1
            self.recommendedCollectionView.alpha = 1
        }, completion: nil)
        
    }
    
    var inWatchList: Bool = false

    @IBAction func addToWatchListPressed(_ sender: Any) {
        //Is NOT Pressed
        if inWatchList == false{
            let alert = UIAlertController(title: "Add show to watchlist?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (uialert) in
                self.saveToWatchlist()
                (sender as! UIBarButtonItem).image = UIImage(named: "addPressed")
                self.inWatchList = true;
            }))
            self.present(alert, animated: true)
        }
        else{
            let alert = UIAlertController(title: "Remove show from watchlist?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (uialert) in
                var tvID: Int?
                if let tv = self.tv{tvID = tv.id}
                else{tvID = self.watchListTvID}
                self.removeFromWatchList(tvID: tvID!)
                (sender as! UIBarButtonItem).image = UIImage(named: "addUnpressed")
                self.inWatchList = false;
            }))
            self.present(alert, animated: true)
        }
    }
    
    func saveToWatchlist(){
       let tv = TvWatch(context: managedObjectContext)
        tv.image = NSData(data: self.backgroundImage.image!.jpegData(compressionQuality: 1)!) as Data
        tv.id = Int32(self.tv.id)
        tv.name = self.tv.name
        do{try self.managedObjectContext.save()}
        catch{print("could not save data \(error.localizedDescription)")}
    }
    
    func removeFromWatchList(tvID:Int){
        let deleteRequest:NSFetchRequest<TvWatch> = TvWatch.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "id==\(tvID)")
        do {
            let objects = try managedObjectContext.fetch(deleteRequest)
            for object in objects {
                managedObjectContext.delete(object)
            }
            try managedObjectContext.save()
        } catch{
            print("Error deleting core data object with id \(tvID) : \(error.localizedDescription)")
        }
    }
    
    func checkIfInWatchlist(tvID:Int){
        let movieRequest:NSFetchRequest<TvWatch> = TvWatch.fetchRequest()
        movieRequest.predicate = NSPredicate(format: "id == %d", tvID)
        do{
            let results = try managedObjectContext.fetch(movieRequest)
            if results.count <= 0{self.inWatchList = false}
            else{self.inWatchList = true}
        }
        catch{
            self.inWatchList = false
            print("Coult not load data from database \(error.localizedDescription)")
        }
    }
    
    func checkDownload(){
        self.semaphore.wait()
        self.totalDownloaded += 1
        if self.totalDownloaded == downloadedRequired{
            self.semaphore.signal()
            DispatchQueue.main.async {
                self.doAnimation()
            }
        }else{self.semaphore.signal()}
    }


}
