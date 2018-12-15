//
//  MovieViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-28.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class MovieViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    //should be 5 when complete
    var totalDownloaded:Int = 0
    
    //watchlist objects
    var watchlistMovieID: Int?
    var watchlistMovieBackgroundImage: UIImage?
    
    
    @IBOutlet weak var noCastLabel: UILabel!
    var managedObjectContext:NSManagedObjectContext!
    
    var movie: Movie!
    var posterUIImage: UIImage!

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playTrailerButton: UIButton!
    @IBOutlet weak var loadingViewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var castAndCrewLabel: UILabel!
    @IBOutlet weak var recomendedLabel: UILabel!
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var posterImageHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var backgroundImage: UIImageView!
    var backgroundImageOrigin: CGPoint!
    var watchlistTitle:String?
    
    @IBOutlet weak var recomendedMovieCollection: UICollectionView!
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    @IBOutlet weak var addToWatchlistButton: UIBarButtonItem!
    
    let movieHelper = MovieHelper()
    let personHelper = PersonHelper()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width*(9/16)))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = UIImage(named: "background Image placeholder")
        backgroundImage.clipsToBounds = true
        self.view.insertSubview(backgroundImage, at: 0)


        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        setUpAnimation()
        if let movie = self.movie{
            setupMovieInfo()
            setOtherScrollViews(id: movie.id)

            self.navigationItem.title = movie.title
            self.downloadBackroundImage()
            posterImage.image = self.posterUIImage
            checkIfInWatchlist(movieID: movie.id)
            
        }else if self.watchlistMovieID != nil{
            setupMovieFromWatchlist()
            if let title = self.watchlistTitle{self.navigationItem.title = title}
            setOtherScrollViews(id: watchlistMovieID!)
            self.inWatchList = true;
        }
        
        if inWatchList{self.addToWatchlistButton.image = UIImage(named: "addPressed")}
        else {self.addToWatchlistButton.image = UIImage(named: "addUnpressed")}
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 118, height: 160)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        castCollectionView.collectionViewLayout = layout
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: 110, height: 190)
        layout2.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout2.minimumLineSpacing = 8
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        recomendedMovieCollection.collectionViewLayout = layout2
        
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: self.backgroundImage.frame.height, left: 0, bottom: 0, right: 0)
        backgroundImage.clipsToBounds = true
        
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        posterImageHeightContraint.constant = -posterImage.frame.height / 3
        posterImage.clipsToBounds = true
        shadowView.addDropShadow()
        noCastLabel.alpha = 0
        
        loadingView.layer.cornerRadius = 10
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.isBeingPresented || self.isMovingToParent {
            self.semaphore.wait()
            totalDownloaded += 1
            if totalDownloaded == 5{
                self.semaphore.signal()
                doAnimation()
            }
            else{self.semaphore.signal()}
        }
    }

    func checkIfInWatchlist(movieID:Int){
        let movieRequest:NSFetchRequest<MovieWatch> = MovieWatch.fetchRequest()
        movieRequest.predicate = NSPredicate(format: "id == %d", movieID)
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
    
    var noCast = false
    func setOtherScrollViews(id: Int){
        personHelper.getPeopleForMovie(movieId: id) { (people) in
            if people.count <= 0{
                self.noCast = true
            }
            else{
                self.castPeople = people
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            }
            self.checkDownload()
        }
        
        movieHelper.downloadRecomendedMovies(movieID: id) { (movies) in
            if movies.count <= 0{
                DispatchQueue.main.async {
                    self.scrollViewBottomConstraint.constant = -self.recomendedMovieCollection.frame.height - self.recomendedLabel.frame.height
                }
            }
            else{
                self.recomendedMovies = movies
                DispatchQueue.main.async {
                    self.recomendedMovieCollection.reloadData()
                    self.recomendedLabel.alpha = 1
                }
            }
            self.checkDownload()
        }
    }
    
    func setupMovieInfo(){
        if let movie = self.movie{
            self.movieTitle.text = self.movie.title
            self.plotLabel.text = movie.overview
            if movie.voteAverage <= 0{
                ratingLabel.text = "Not Rated"
            }else{
                ratingLabel.text = "\(Int(movie.voteAverage*10))%"
            }
            movieHelper.downloadMovieInfo(movieID: movie.id) { (details) in
                DispatchQueue.main.async {
                    if let run = details.runtime{
                        self.runTimeLabel.text = run.toRunTime()
                    }else{
                        self.runTimeLabel.text = "Run Time: Not Available"
                    }
                    if let date = details.releaseDate{
                        self.releaseDateLabel.text = date.changeDateFormating()
                    }else{
                        self.releaseDateLabel.text = "Not Available"
                    }
                }
                self.checkDownload()
            }
        }
    }
    
    func checkDownload(){
        self.semaphore.wait()
        self.totalDownloaded += 1
        if self.totalDownloaded == 5{
            self.semaphore.signal()
            DispatchQueue.main.async {
                self.doAnimation()
            }
        }else{self.semaphore.signal()}
    }
    
    func setupMovieFromWatchlist(){
        let id = self.watchlistMovieID!
        self.movie = Movie()
        self.movie.id = id
        self.backgroundImage.image = self.watchlistMovieBackgroundImage
        movieHelper.downloadWatchlistMovieInfo(movieID: id) { (movieInfo) in
            self.movie.voteAverage = movieInfo.voteAverage
            DispatchQueue.main.async {
                self.movieTitle.text = movieInfo.title
                self.plotLabel.text = movieInfo.overview
                if movieInfo.voteAverage<=0{self.ratingLabel.text = "Not Rated"}
                else{self.ratingLabel.text = "\(Int(movieInfo.voteAverage*10))%"}
                if let run = movieInfo.runtime{self.runTimeLabel.text = run.toRunTime()}
                else{self.runTimeLabel.text = "Run Time: Not Available"}
                if let date = movieInfo.releaseDate{
                    self.releaseDateLabel.text = date.changeDateFormating()
                }else{self.releaseDateLabel.text = "Not Available"}
                self.downloadPosterImage(posterPath: movieInfo.posterPath)
            }
            self.checkDownload()
        }
    }
    
    func downloadBackroundImage(){
        if let backdropUrl = movie.backdropPath{
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
        }
        else{
            self.checkDownload()
        }
    }
    
    var height:CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.scrollView){
            let offsetY = -scrollView.contentOffset.y
            let height = max(0, offsetY)
            self.height = height
            backgroundImage.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.height)
        }
    }
    
    var castPeople: [Person] = [Person]()
    var recomendedMovies: [Movie] = [Movie]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.castCollectionView{
            return castPeople.count
        }
        if collectionView == self.recomendedMovieCollection{
            return recomendedMovies.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.castCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! PeopleCollectionViewCell
            cell.profilePicture.image = #imageLiteral(resourceName: "Person Placeholder Image")
            let person = self.castPeople[indexPath.row]
            cell.actorNameLabel.text = person.name
            cell.characterNameLabel.text = person.character
            if let imageUrl = person.profilePath{
                cell.profilePicture.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
            }
        return cell
      }
        
        /*if collectionView == self.recomendedMovieCollection*/ else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
            cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
            let movie = self.recomendedMovies[indexPath.row]
            cell.movieTitle.text = movie.title
            if let imageUrl = movie.posterPath{
                cell.posterImage.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w154\(imageUrl)")
            }
            return cell
        }
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recomendedMovieCollection{
            let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            let imageToSend1 = cell.posterImage.image
            let movieToSend1 = recomendedMovies[indexPath.row]
            if let dest = self.storyboard?.instantiateViewController(withIdentifier: "MovieController") as? MovieViewController{
                dest.posterUIImage = imageToSend1
                dest.movie = movieToSend1
                self.navigationController?.pushViewController(dest, animated: true)
            }
        }
        else if collectionView == castCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! PeopleCollectionViewCell
            imageToSend = cell.profilePicture.image
            personToSend = self.castPeople[indexPath.row]
            performSegue(withIdentifier: "MovieToPerson", sender: self)
        }
    }
    
    var personToSend:Person?
    var imageToSend:UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieToTrailer"{
            if let dest = segue.destination as? TrailerViewController{
                dest.movieID = self.movie.id
                dest.type = .movie
            }
        }
        else if segue.identifier == "MovieToPerson"{
            if let dest = segue.destination as? PersonViewController{
                dest.person = personToSend
                dest.personImage = imageToSend
            }
        }
    }

    
    //all the constraints
    
    @IBOutlet weak var posterImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var releaseDateLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var releaseDateConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plotLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plotConstraint: NSLayoutConstraint!
    //should be called in viewDidLoad()
    func setUpAnimation(){
        self.backgroundImage.alpha = 0
        movieTitle.alpha = 0
        runTimeLabel.alpha = 0
        self.ratingLabel.alpha = 0
        self.ratingView.alpha = 0
        self.castCollectionView.alpha = 0
        self.castAndCrewLabel.alpha = 0
        self.recomendedLabel.alpha = 0
        self.recomendedMovieCollection.alpha = 0
        self.playTrailerButton.alpha = 0
        posterImageConstraint.constant = -posterImage.frame.width - 4
        releaseDateLabelConstraint.constant = -self.view.frame.width
        releaseDateConstraint.constant = -self.view.frame.width
        plotConstraint.constant = -self.view.frame.width
        plotLabelConstraint.constant = -self.view.frame.width
        addToWatchlistButton.isEnabled = false
    }
    
    func doAnimation(){
        addToWatchlistButton.isEnabled = true
        loadingView.alpha = 0
        loadingViewIndicator.stopAnimating()

        if movie.voteAverage > 0{
            let amount = CGFloat(movie.voteAverage / 10)
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                self.ratingView.ratingAmount.frame.size.width = self.ratingView.frame.width * (amount)
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundImage.alpha = 1
            self.movieTitle.alpha = 1
            self.runTimeLabel.alpha = 1
            self.posterImageConstraint.constant = 15
            self.ratingLabel.alpha = 1
            self.ratingView.alpha = 1
            self.playTrailerButton.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.releaseDateLabelConstraint.constant = 15
            self.releaseDateConstraint.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.6, delay: 0.35, options: .curveEaseOut, animations: {
            self.plotConstraint.constant = 15
            self.plotLabelConstraint.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: {
            self.castCollectionView.alpha = 1
            self.recomendedMovieCollection.alpha = 1
            self.castAndCrewLabel.alpha = 1
            if self.recomendedMovies.count == 0{
                self.recomendedLabel.alpha = 0
            }
            else{
                self.recomendedLabel.alpha = 1
            }
        }, completion: nil)
        if noCast{
            noCastLabel.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: {
                self.noCastLabel.alpha = 1
            },completion: nil)
        }
    }
    
    var inWatchList: Bool = false
    
    @IBAction func addToWatchlist(_ sender: UIBarButtonItem) {
        //Is NOT Pressed
        if inWatchList == false{
            let alert = UIAlertController(title: "Add movie to watchlist?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (uialert) in
                self.saveToWatchlist()
                sender.image = UIImage(named: "addPressed")
                self.inWatchList = true;
            }))
            self.present(alert, animated: true)
        }
        //Is Pressed
        else{
            let alert = UIAlertController(title: "Remove movie from watchlist?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (uialert) in
                var movieID: Int?
                if let mov = self.movie{movieID = mov.id}
                else{movieID = self.watchlistMovieID}
                self.removeFromWatchlist(movieID: movieID!)
                sender.image = UIImage(named: "addUnpressed")
                self.inWatchList = false;
            }))
            self.present(alert, animated: true)
        }
    }
    
    func saveToWatchlist(){
        let movie = MovieWatch(context: managedObjectContext)
        movie.image = NSData(data: self.backgroundImage.image!.jpegData(compressionQuality: 1)!) as Data
        movie.id = Int32(self.movie.id)
        movie.name = self.movie.title
        do{try self.managedObjectContext.save()}
        catch{print("Could not save data \(error.localizedDescription)")}
    }
    
    func removeFromWatchlist(movieID:Int){
        let deleteRequest:NSFetchRequest<MovieWatch> = MovieWatch.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "id==\(movieID)")
        do {
            let objects = try managedObjectContext.fetch(deleteRequest)
            for object in objects {
                managedObjectContext.delete(object)
            }
            try managedObjectContext.save()
        } catch{
            print("Error deleting core data object with id \(movieID) : \(error.localizedDescription)")
        }
    }
}
