//
//  ViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-22.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit


class DiscoverViewController: UIViewController, UIScrollViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var topSeeAllButton: UIButton!
    @IBOutlet weak var middleSeeAllButton: UIButton!
    @IBOutlet weak var thirdSeeAllButton: UIButton!
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popularMoviesCollection: UICollectionView!
    
    @IBOutlet weak var comingSoonCollection: UICollectionView!
    @IBOutlet weak var newReleasesCollection: UICollectionView!
    
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var segmentedTopConstraint: NSLayoutConstraint!
    
    let movieHelper: MovieHelper = MovieHelper()
    let tvHelper: TvHelper = TvHelper()
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchMovies()
        fetchTv()
        self.scrollView.delegate = self
        self.popularMoviesCollection.dataSource = self
        self.popularMoviesCollection.delegate = self
        self.newReleasesCollection.dataSource = self
        self.newReleasesCollection.delegate = self
        self.comingSoonCollection.dataSource = self
        self.comingSoonCollection.delegate = self
        
        popularMoviesCollection.collectionViewLayout.invalidateLayout()
        newReleasesCollection.collectionViewLayout.invalidateLayout()
        comingSoonCollection.collectionViewLayout.invalidateLayout()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 190)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 13.5, bottom: 0, right: 13.5)
        
        popularMoviesCollection.collectionViewLayout = layout
        newReleasesCollection.collectionViewLayout = layout
        comingSoonCollection.collectionViewLayout = layout
                
        scrollView.contentInset = UIEdgeInsets(top: self.segmentedView.frame.height, left: 0, bottom: 0, right: 0)
        
        self.loadingView.alpha = 0
        self.loadingView.layer.cornerRadius = 10
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.isBeingPresented || self.isMovingToParent {
            self.popularMoviesCollection.reloadData()
            self.newReleasesCollection.reloadData()
            self.comingSoonCollection.reloadData()
        }
    }
    
    func fetchMovies(){
        movieHelper.downloadMovies(type: .popular, page: 1) { (movies) in
            self.allMovieData.popularMovies = movies
            DispatchQueue.main.async {
                self.popularMoviesCollection.reloadData()
            }

        }
        movieHelper.downloadMovies(type: .new, page: 1) { (movies) in
            self.allMovieData.newMovies = movies
            DispatchQueue.main.async {
                self.newReleasesCollection.reloadData()
            }
        }
        movieHelper.downloadMovies(type: .comingSoon, page: 1) { (movies) in
            self.allMovieData.upComingMovies = movies
            DispatchQueue.main.async {
                self.comingSoonCollection.reloadData()
            }

        }

    }
    
    func fetchTv(){
        tvHelper.downloadTv(type: .popular, page: 1) { (shows) in
            self.allTvData.popularTv = shows
            self.checkDownload()
        }
        tvHelper.downloadTv(type: .onAir, page: 1) { (shows) in
            self.allTvData.onAirTv = shows
            self.checkDownload()
        }
        tvHelper.downloadTv(type: .airingToday, page: 1) { (shows) in
            self.allTvData.airingTodayTv = shows
            self.checkDownload()
        }
    }

    class MovieCollectionData {
        var popularMovies = [Movie]()
        var newMovies = [Movie]()
        var upComingMovies = [Movie]()
    }
    class TvCollectionData {
        var popularTv = [Tv]()
        var onAirTv = [Tv]()
        var airingTodayTv = [Tv]()
    }
    var allMovieData: MovieCollectionData = MovieCollectionData()
    var allTvData: TvCollectionData = TvCollectionData()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            if (scrollView.contentOffset.y + segmentedView.frame.height) < 0{
                segmentedTopConstraint.constant = -(scrollView.contentOffset.y + segmentedView.frame.height) - 5
                self.view.layoutIfNeeded()
            }
            else{
                segmentedTopConstraint.constant = -5
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            if collectionView == self.popularMoviesCollection{
                return self.allMovieData.popularMovies.count
            }
            else if collectionView == self.newReleasesCollection{
                return self.allMovieData.newMovies.count
            }
            else if collectionView == self.comingSoonCollection{
                return self.allMovieData.upComingMovies.count
            }
            
        case 1:
            if collectionView == self.popularMoviesCollection{
                return self.allTvData.popularTv.count
            }
            else if collectionView == self.newReleasesCollection{
                return self.allTvData.onAirTv.count
            }
            else if collectionView == self.comingSoonCollection{
                return self.allTvData.airingTodayTv.count
            }
            
        default:
            break
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        let movie: Movie!
        let tv: Tv!
        
        cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
        
        switch segmentedView.selectedSegmentIndex {
            //movies
        case 0:
            if collectionView == self.popularMoviesCollection{
                movie = self.allMovieData.popularMovies[indexPath.row]
            }
            else if collectionView == self.newReleasesCollection{
                movie = self.allMovieData.newMovies[indexPath.row]
            }
            else if collectionView == self.comingSoonCollection{
                movie = self.allMovieData.upComingMovies[indexPath.row]
            }else {movie = Movie()}
            
            cell.movieTitle.text = movie.title
            
            if movie.posterPath != "" && movie.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(movie.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)
            }
            //tv
        case 1:
            if collectionView == self.popularMoviesCollection{
                tv = self.allTvData.popularTv[indexPath.row]
            }
            else if collectionView == self.newReleasesCollection{
                tv = self.allTvData.onAirTv[indexPath.row]
            }
            else if collectionView == self.comingSoonCollection{
                tv = self.allTvData.airingTodayTv[indexPath.row]
            }
            else{tv = Tv()}
            cell.movieTitle.text = tv.name
            
            if tv.posterPath != "" && tv.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(tv.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)
            }
        default:
            break
        }

        return cell
       
    }
    
    var movieToSend: Movie!
    var imageToSend: UIImage!
    var tvToSend: Tv!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        imageToSend = cell.posterImage.image
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            if collectionView == self.popularMoviesCollection{
                movieToSend = self.allMovieData.popularMovies[indexPath.row]
            }
            else if collectionView == self.newReleasesCollection{
                movieToSend = self.allMovieData.newMovies[indexPath.row]
            }
            else if collectionView == self.comingSoonCollection{
                movieToSend = self.allMovieData.upComingMovies[indexPath.row]
            }
            else{
                movieToSend = Movie()
            }
            performSegue(withIdentifier: "DiscoverToMovie", sender: self)
        case 1:
            if collectionView == self.popularMoviesCollection{
                tvToSend = self.allTvData.popularTv[indexPath.row]
            }
            else if collectionView == self.newReleasesCollection{
                tvToSend = self.allTvData.onAirTv[indexPath.row]
            }
            else if collectionView == self.comingSoonCollection{
                tvToSend = self.allTvData.airingTodayTv[indexPath.row]
            }
            performSegue(withIdentifier: "DiscoverToTv", sender: self)
        default:
            break
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DiscoverToMovie"{
            if let dest = segue.destination as? MovieViewController{
                dest.movie = movieToSend
                dest.posterUIImage = imageToSend
            }
            return
        }
        if segue.identifier == "DiscoverToTv"{
            if let dest = segue.destination as? TVViewController{
                dest.tv = self.tvToSend
                dest.posterUIImage = self.imageToSend
            }
        }
        if segue.identifier == "seeMorePopular"{
            if let dest = segue.destination as? DiscoverTypeViewController{
                dest.catagory = MoviesType.popular
                switch self.segmentedView.selectedSegmentIndex{
                case 0:
                    dest.movies = self.allMovieData.popularMovies
                    dest.isMovies = true
                case 1:
                    dest.tv = self.allTvData.popularTv
                    dest.isMovies = false
                default:
                    break
                }

            }
            return
        }
        if segue.identifier == "seeMoreNew"{
            if let dest = segue.destination as? DiscoverTypeViewController{
                dest.catagory = MoviesType.newReleases
                switch self.segmentedView.selectedSegmentIndex{
                case 0:
                    dest.movies = self.allMovieData.newMovies
                    dest.isMovies = true
                case 1:
                    dest.tv = self.allTvData.onAirTv
                    dest.isMovies = false
                default:
                    break
                }
            }
            return
        }
        if segue.identifier == "seeMoreUpComing"{
            if let dest = segue.destination as? DiscoverTypeViewController{
                dest.catagory = MoviesType.upComing
                switch self.segmentedView.selectedSegmentIndex{
                case 0:
                    dest.movies = self.allMovieData.upComingMovies
                    dest.isMovies = true
                case 1:
                    dest.tv = self.allTvData.airingTodayTv
                    dest.isMovies = false
                default:
                    break
                }

            }
            return
        }
    }

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    
    var topMovieOffset:CGFloat = 0
    var middleMovieOffset:CGFloat = 0
    var bottomMovieOffset:CGFloat = 0
    
    var topTvOffset:CGFloat = 0
    var middleTvOffset:CGFloat = 0
    var bottomTvOffset:CGFloat = 0

    
    @IBAction func SegmentedChanged(_ sender: Any) {
        firstLabel.alpha = 0
        secondLabel.alpha = 0
        thirdLabel.alpha = 0
        popularMoviesCollection.alpha = 0
        comingSoonCollection.alpha = 0
        newReleasesCollection.alpha = 0
        
        
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            
            if loadingIcon.isAnimating{
                loadingView.alpha = 0
                loadingIcon.stopAnimating()
                topSeeAllButton.alpha = 1
                middleSeeAllButton.alpha = 1
                thirdSeeAllButton.alpha = 1
            }
            
            //save tv offset
            topTvOffset = popularMoviesCollection.contentOffset.x
            middleTvOffset = newReleasesCollection.contentOffset.x
            bottomTvOffset = comingSoonCollection.contentOffset.x
            
            secondLabel.text = "New Releases"
            thirdLabel.text = "Coming Soon"
            
            //load original offsets
            popularMoviesCollection.setContentOffset(CGPoint(x: topMovieOffset, y: 0), animated: false)
            newReleasesCollection.setContentOffset(CGPoint(x: middleMovieOffset, y: 0), animated: false)
            comingSoonCollection.setContentOffset(CGPoint(x: bottomMovieOffset, y: 0), animated: false)
            
        case 1:
            //save movie offset
            topMovieOffset = popularMoviesCollection.contentOffset.x
            middleMovieOffset = newReleasesCollection.contentOffset.x
            bottomMovieOffset = comingSoonCollection.contentOffset.x
            
            semaphore.wait()
            if totalDownloaded < 3{
                loadingView.alpha = 1
                loadingIcon.startAnimating()
                topSeeAllButton.alpha = 0
                middleSeeAllButton.alpha = 0
                thirdSeeAllButton.alpha = 0
                semaphore.signal()
                return
            }
            semaphore.signal()
            
            secondLabel.text = "On The Air"
            thirdLabel.text = "Airing Today"
            
            //load original offsets
            popularMoviesCollection.setContentOffset(CGPoint(x: topTvOffset, y: 0), animated: false)
            newReleasesCollection.setContentOffset(CGPoint(x: middleTvOffset, y: 0), animated: false)
            comingSoonCollection.setContentOffset(CGPoint(x: bottomTvOffset, y: 0), animated: false)

        default:
            break
        }
        
        //reload collection views
        self.popularMoviesCollection.reloadData()
        self.comingSoonCollection.reloadData()
        self.newReleasesCollection.reloadData()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.firstLabel.alpha = 1
            self.secondLabel.alpha = 1
            self.thirdLabel.alpha = 1
            self.popularMoviesCollection.alpha = 1
            self.comingSoonCollection.alpha = 1
            self.newReleasesCollection.alpha = 1
        }, completion: nil)

    }
    
    func checkDownload(){
        self.semaphore.wait()
        self.totalDownloaded += 1
        if self.totalDownloaded == 3{
            self.semaphore.signal()
            DispatchQueue.main.async {
                if self.segmentedView.selectedSegmentIndex == 1{
                    self.loadingView.alpha = 0
                    self.loadingIcon.stopAnimating()
                    self.topSeeAllButton.alpha = 1
                    self.middleSeeAllButton.alpha = 1
                    self.thirdSeeAllButton.alpha = 1
                    
                    self.secondLabel.text = "On The Air"
                    self.thirdLabel.text = "Airing Today"
                    
                    //reload collection views
                    self.popularMoviesCollection.reloadData()
                    self.comingSoonCollection.reloadData()
                    self.newReleasesCollection.reloadData()
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                        self.firstLabel.alpha = 1
                        self.secondLabel.alpha = 1
                        self.thirdLabel.alpha = 1
                        self.popularMoviesCollection.alpha = 1
                        self.comingSoonCollection.alpha = 1
                        self.newReleasesCollection.alpha = 1
                    }, completion: nil)
                }

            }
        }else{self.semaphore.signal()}
    }

    
}

