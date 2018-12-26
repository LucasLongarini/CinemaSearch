//
//  DiscoverTypeViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-06.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

enum MoviesType{
    case popular
    case upComing
    case newReleases
}


class DiscoverTypeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewActivity: UIActivityIndicatorView!
    @IBOutlet weak var moviesCollection: UICollectionView!
    var catagory: MoviesType!
    var movies: [Movie]!
    var tv: [Tv]!
    let movieHelper = MovieHelper()
    let tvHelper = TvHelper()
    var isMovies: Bool!
    
    var tempMovie = [Movie]()
    var tempTv = [Tv]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.catagory {
        case .popular?:
            if isMovies{self.navigationItem.title = "Popular Movies"}
            else{self.navigationItem.title = "Popular Tv"}
        case .upComing?:
            if isMovies{self.navigationItem.title = "Movies Coming Soon"}
            else{self.navigationItem.title = "Tv Airing Today"}
        case .newReleases?:
            if isMovies{self.navigationItem.title = "New Movie Releases"}
            else{self.navigationItem.title = "Tv On The Air"}
        default:
            break
        }
        
        if isMovies{
            let remainder = (self.movies.count % 3)
            if remainder != 0{
                for _ in 0...(remainder - 1){
                    if let mov = self.movies.popLast(){
                        tempMovie.append(mov)
                    }
                }
            }
        }
        else{
            let remainder = (self.tv.count % 3)
            if remainder != 0{
                for _ in 0...(remainder - 1){
                    if let tv = self.tv.popLast(){
                        tempTv.append(tv)
                    }
                }
            }
        }
        
        loadingView.layer.cornerRadius = 10
        loadingView.alpha = 0
        loadingViewActivity.stopAnimating()
        
        let itemSize = UIScreen.main.bounds.width / 3 - 8 //* (4)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize * (190/110))
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8 + 5.5, left: 8, bottom: 8 + 5.5, right: 8)
        moviesCollection.collectionViewLayout = layout
        
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isMovies{
            return movies.count
        }
        else{
            return tv.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
        if isMovies{
            let movie = movies[indexPath.row]
            cell.movieTitle.text = movie.title
            if movie.posterPath != "" && movie.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(movie.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)
            }
        }
        else{
            let tv = self.tv[indexPath.row]
            cell.movieTitle.text = tv.name
            if tv.posterPath != "" && tv.posterPath != nil{
                let urlString = "https://image.tmdb.org/t/p/w154\(tv.posterPath!)"
                cell.posterImage.loadImageUsingCache(urlString: urlString)
            }
        }
        return cell
    }

    var imageToSend: UIImage!
    var movieToSend: Movie!
    var tvToSend: Tv!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        imageToSend = cell.posterImage.image
        if isMovies{
            movieToSend = self.movies[indexPath.row]
            performSegue(withIdentifier: "DiscoverTypeToMovie", sender: self)
        }
        else{
            tvToSend = self.tv[indexPath.row]
            performSegue(withIdentifier: "DiscoverTypeToTV", sender: self)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DiscoverTypeToMovie"{
            if let dest = segue.destination as? MovieViewController{
                dest.movie = movieToSend
                dest.posterUIImage = imageToSend
            }
        }
        else if segue.identifier == "DiscoverTypeToTV"{
            if let dest = segue.destination as? TVViewController{
                dest.tv = tvToSend
                dest.posterUIImage = imageToSend
            }
        }
    }
    
    var fetchingMore = false
    var pagesFetched = 1
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if !fetchingMore{
                getMoreMovies()
            }
        }
    }
    
    func getMoreMovies(){
        fetchingMore = true
        pagesFetched += 1
        
        loadingViewActivity.startAnimating()
        loadingView.alpha = 1
        
        switch self.catagory {
        case .popular?:
            if isMovies{
                movieHelper.downloadMovies(type: .popular, page: pagesFetched) { (movies) in
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }else{
                tvHelper.downloadTv(type: .popular, page: pagesFetched) { (shows) in
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }
        case .upComing?:
            if isMovies{
                movieHelper.downloadMovies(type: .comingSoon, page: pagesFetched) { (movies) in
                    if movies.count == 0{
                        //truncate here
                        if self.tempMovie.count != 0{
                            for _ in 0...(self.tempMovie.count - 1){
                                if let mov = self.tempMovie.popLast(){
                                    self.movies.append(mov)
                                }
                            }
                            DispatchQueue.main.async {
                                self.loadingView.alpha = 0
                                self.loadingViewActivity.stopAnimating()
                                self.moviesCollection.reloadData()
                            }
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.loadingViewActivity.stopAnimating()
                            self.loadingView.alpha = 0
                        })
                        return
                    }
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }
            else{
                tvHelper.downloadTv(type: .airingToday, page: pagesFetched) { (shows) in
                    if shows.count == 0{
                        //truncate here
                        if self.tempTv.count != 0{
                            for _ in 0...(self.tempTv.count - 1){
                                if let tv = self.tempTv.popLast(){
                                    self.tv.append(tv)
                                }
                            }
                            DispatchQueue.main.async {
                                self.loadingView.alpha = 0
                                self.loadingViewActivity.stopAnimating()
                                self.moviesCollection.reloadData()
                            }
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.loadingViewActivity.stopAnimating()
                            self.loadingView.alpha = 0
                        })
                        return
                    }
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }
        case .newReleases?:
            if isMovies{
                movieHelper.downloadMovies(type: .new, page: pagesFetched) { (movies) in
                    if movies.count == 0{
                        if self.tempMovie.count != 0{
                            for _ in 0...(self.tempMovie.count - 1){
                                if let mov = self.tempMovie.popLast(){
                                    self.movies.append(mov)
                                }
                            }
                            DispatchQueue.main.async {
                                self.loadingView.alpha = 0
                                self.loadingViewActivity.stopAnimating()
                                self.moviesCollection.reloadData()
                            }
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.loadingViewActivity.stopAnimating()
                            self.loadingView.alpha = 0
                        })
                        return
                    }
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }else{
                tvHelper.downloadTv(type: .onAir, page: pagesFetched) { (shows) in
                    if shows.count == 0{
                        if self.tempTv.count != 0{
                            for _ in 0...(self.tempTv.count - 1){
                                if let tv = self.tempTv.popLast(){
                                    self.tv.append(tv)
                                }
                            }
                            DispatchQueue.main.async {
                                self.loadingView.alpha = 0
                                self.loadingViewActivity.stopAnimating()
                                self.moviesCollection.reloadData()
                            }
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.loadingViewActivity.stopAnimating()
                            self.loadingView.alpha = 0
                        })
                        return
                    }
                    //truncate
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
                        self.moviesCollection.reloadData()
                        self.fetchingMore = false
                        self.loadingViewActivity.stopAnimating()
                        self.loadingView.alpha = 0
                    }
                }
            }
        default:
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
}
