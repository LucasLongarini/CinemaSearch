//
//  TopRatedViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-01.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class TopRatedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0
    
    @IBOutlet weak var segmnetedView: TabbedSegmentedControl!
    
    @IBOutlet weak var segmentedViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    var movies: [Movie] = [Movie]()
    var tv: [Tv] = [Tv]()
    let movieHelper = MovieHelper()
    let tvHelper = TvHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moviesCollectionView.alpha = 0
        movieHelper.downloadMovies(type: .topRated, page: 1) { (movies) in
            self.movies = movies
            let remainder:Int = (movies.count % 3)
            if remainder != 0 && movies.count > 18{
                for _ in 0...(remainder - 1) {
                    if let mov = self.movies.popLast(){
                        self.tempMovie.append(mov)
                    }
                }
            }
            self.semaphore.wait()
            self.totalDownloaded += 1
            if self.totalDownloaded == 2{
                self.semaphore.signal()
                DispatchQueue.main.async {
                    self.loadingView.alpha = 0
                    self.loadingActivityIndicator.stopAnimating()
                    self.moviesCollectionView.reloadData()
                    UIView.animate(withDuration: 0.3) {self.moviesCollectionView.alpha = 1}
                }
            }else{self.semaphore.signal()}
        }
        tvHelper.downloadTv(type: .topRated, page: 1) { (shows) in
            self.tv = shows
            let remainder:Int = (shows.count % 3)
            if remainder != 0 && shows.count > 18{
                for _ in 0...(remainder - 1) {
                    if let tv = self.tv.popLast(){
                        self.tempTv.append(tv)
                    }
                }
            }
            self.semaphore.wait()
            self.totalDownloaded += 1
            if self.totalDownloaded == 2{
                self.semaphore.signal()
                DispatchQueue.main.async {
                    self.loadingView.alpha = 0
                    self.loadingActivityIndicator.stopAnimating()
                    self.moviesCollectionView.reloadData()
                    UIView.animate(withDuration: 0.3) {self.moviesCollectionView.alpha = 1}
                }
            }else{self.semaphore.signal()}
        }
        
        let itemSize = (UIScreen.main.bounds.width / 3) - 8 

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize * (190/110))
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 12 , left: 8, bottom: 12, right: 8)
        moviesCollectionView.collectionViewLayout = layout
        
        loadingView.layer.cornerRadius = 10
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmnetedView.selectedSegmentIndex {
        case 0:
            return movies.count
        case 1:
            return tv.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
        switch segmnetedView.selectedSegmentIndex {
        case 0:
            let movie = movies[indexPath.row]
            cell.movieTitle.text = movie.title
            if movie.posterPath != "" && movie.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(movie.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)
            }
        case 1:
            let tv = self.tv[indexPath.row]
            cell.movieTitle.text = tv.name
            if tv.posterPath != "" && tv.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(tv.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)            }
        default:
            break
        }

        return cell
    }
    
    var movieToSend: Movie!
    var tvToSend: Tv!
    var imageToSend: UIImage!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        imageToSend = cell.posterImage.image
        switch segmnetedView.selectedSegmentIndex {
        case 0:
            movieToSend = self.movies[indexPath.row]
            performSegue(withIdentifier: "TopRatedToMovie", sender: self)
        case 1:
            tvToSend = self.tv[indexPath.row]
            performSegue(withIdentifier: "TopToTv", sender: self)
        default:
            break
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TopRatedToMovie"{
            if let dest = segue.destination as? MovieViewController{
                dest.movie = movieToSend
                dest.posterUIImage = imageToSend
            }
        }
        else if segue.identifier == "TopToTv"{
            if let dest = segue.destination as? TVViewController{
                dest.tv = tvToSend
                dest.posterUIImage = imageToSend
            }
        }
    }
    
    var fetchingMore = false
    var moviePagesFetched = 1
    var tvPagesFetched = 1

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y) < 0{
            segmentedViewTopConstraint.constant = -(scrollView.contentOffset.y) - 5
            self.view.layoutIfNeeded()
        }else{
            segmentedViewTopConstraint.constant = -5
        }
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if !fetchingMore{
                getMoreMovies()
            }
        }
    }
    
    //need to add option if no movies fetched
    
    var tempMovie: [Movie] = [Movie]()
    var tempTv:[Tv] = [Tv]()
    
    func getMoreMovies(){
        fetchingMore = true
        loadingView.alpha = 1
        loadingActivityIndicator.startAnimating()
        switch self.segmnetedView.selectedSegmentIndex {
        case 0:
            self.moviePagesFetched += 1
            movieHelper.downloadMovies(type: .topRated, page: moviePagesFetched) { (movies) in
                if self.tempMovie.count != 0{
                    for _ in 0...(self.tempMovie.count - 1){
                        if let mov = self.tempMovie.popLast(){
                            self.movies.append(mov)
                        }
                    }
                }
                self.movies.append(contentsOf: movies)
                let remainder:Int = (self.movies.count % 3)
                if remainder != 0{
                    for _ in 0...(remainder - 1) {
                        if let mov = self.movies.popLast(){
                            self.tempMovie.append(mov)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.moviesCollectionView.reloadData()
                    self.fetchingMore = false
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingView.alpha = 0
                }
            }
        case 1:
            self.tvPagesFetched += 1
            tvHelper.downloadTv(type: .topRated, page: tvPagesFetched) { (shows) in
                if self.tempTv.count != 0{
                    for _ in 0...(self.tempTv.count - 1){
                        if let tv = self.tempTv.popLast(){
                            self.tv.append(tv)
                        }
                    }
                }
                self.tv.append(contentsOf: shows)
                let remainder:Int = (self.tv.count % 3)
                if remainder != 0{
                    for _ in 0...(remainder - 1){
                        if let tv = self.tv.popLast(){
                            self.tempTv.append(tv)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.moviesCollectionView.reloadData()
                    self.fetchingMore = false
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingView.alpha = 0
                }
            }
        default:
            break
        }


    }
    
    var movieOffset: CGFloat = 0
    var tvOffset:CGFloat = 0

    @IBAction func segmentedChanged(_ sender: Any) {
        switch self.segmnetedView.selectedSegmentIndex {
        case 0:
            if self.movies.count > 0 && self.loadingActivityIndicator.isAnimating{
                self.loadingActivityIndicator.stopAnimating()
                self.loadingView.alpha = 0
            }
            else if self.movies.count == 0 && !self.loadingActivityIndicator.isAnimating{
                self.loadingActivityIndicator.startAnimating()
                self.loadingView.alpha = 1
            }
            //save tv offset
            tvOffset = self.moviesCollectionView.contentOffset.y
            self.moviesCollectionView.setContentOffset(CGPoint(x: 0, y: movieOffset), animated: false)
        case 1:
            if self.tv.count > 0 && self.loadingActivityIndicator.isAnimating{
                self.loadingActivityIndicator.stopAnimating()
                self.loadingView.alpha = 0
            }
            else if self.tv.count == 0 && !self.loadingActivityIndicator.isAnimating{
                self.loadingActivityIndicator.startAnimating()
                self.loadingView.alpha = 1
            }
            //save movie offset
            movieOffset = self.moviesCollectionView.contentOffset.y
            self.moviesCollectionView.setContentOffset(CGPoint(x: 0, y: tvOffset), animated: false)
        default:
            break
        }
        //moviesCollectionView.contentOffset.y = 0
        self.moviesCollectionView.alpha = 0
        self.moviesCollectionView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.moviesCollectionView.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
}
