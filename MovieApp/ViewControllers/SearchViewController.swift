//
//  SearchViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-01.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var noResultsLabel: UILabel!
    
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    let searchBar = UISearchBar()
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var movieResultsCollection: UICollectionView!
    var movieResults = [Movie]()
    var tvResults = [Tv]()
    let movieHelper = MovieHelper()
    let tvHelper = TvHelper()
    
    var lastSearchedMovies: String = ""
    var lastSearchedTv: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.layer.cornerRadius = 10
        loadingView.alpha = 0
        createSearchBar()
        
        
        let itemSize = UIScreen.main.bounds.width / 3 - 8
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize * (190/110))
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8 + 5.5, left: 8, bottom: 8 + 5.5, right: 8)
        movieResultsCollection.collectionViewLayout = layout
        
    }
    
    var movieOffset: CGFloat = 0
    var tvOffset:CGFloat = 0
    @IBAction func segmentedChanged(_ sender: Any) {
        switch segmentedView.selectedSegmentIndex{
        case 0:
            tvOffset = self.movieResultsCollection.contentOffset.y
            self.movieResultsCollection.setContentOffset(CGPoint(x: 0, y: movieOffset), animated: false)
            self.searchBar.placeholder = "Search Movies"
            if self.movieResults.count == 0{
                noResultsLabel.alpha = 1
            }else{
                noResultsLabel.alpha = 0
            }
            searchBar.text = lastSearchedMovies
        case 1:
            movieOffset = self.movieResultsCollection.contentOffset.y
            self.movieResultsCollection.setContentOffset(CGPoint(x: 0, y: tvOffset), animated: false)
            self.searchBar.placeholder = "Search TV-Shows"
            if self.tvResults.count == 0{
                noResultsLabel.alpha = 1
            }else{
                noResultsLabel.alpha = 0
            }
            searchBar.text =  lastSearchedTv
        default:
            break
        }
        self.movieResultsCollection.alpha = 0
        self.movieResultsCollection.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.movieResultsCollection.alpha = 1
        }
    }
    
    func createSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search Movies"
        searchBar.keyboardType = UIKeyboardType.asciiCapable
        searchBar.returnKeyType = UIReturnKeyType.search
        searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    var tempMovie:[Movie] = [Movie]()
    var tempTv:[Tv] = [Tv]()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadingView.alpha = 1
        activityIcon.startAnimating()
        self.movieResultsCollection.contentOffset.y = 0
        self.fetchingMoreTv = false
        self.fetchingMoreMovies = false
        switch segmentedView.selectedSegmentIndex {
        case 0:
            if searchBar.text == self.lastSearchedMovies{
                DispatchQueue.main.async {
                    self.loadingView.alpha = 0
                    self.activityIcon.stopAnimating()
                }
                return
            }
            movieHelper.searchMovies(query: searchBar.text!, page: 1) { (movies) in
                self.movieResults.removeAll()
                
                if movies.count == 0{
                    self.movieResults = movies
                    DispatchQueue.main.async {
                        self.noResultsLabel.alpha = 1
                        self.movieResultsCollection.reloadData()
                        self.loadingView.alpha = 0
                        self.activityIcon.stopAnimating()
                    }
                    return
                }
                //truncate here
                self.movieResults = movies
                let remainder:Int = (movies.count % 3)
                if remainder != 0 && movies.count > 18{
                    for _ in 0...(remainder - 1) {
                        if let mov = self.movieResults.popLast(){
                            self.tempMovie.append(mov)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.noResultsLabel.alpha = 0
                    self.movieResultsCollection.reloadData()
                    self.loadingView.alpha = 0
                    self.activityIcon.stopAnimating()
                }
            }
            self.lastSearchedMovies = searchBar.text ?? ""
        case 1:
            if searchBar.text == self.lastSearchedTv{
                DispatchQueue.main.async {
                    self.loadingView.alpha = 0
                    self.activityIcon.stopAnimating()
                }
                return
            }
            tvHelper.searchTVShows(query: searchBar.text!, page: 1) { (shows) in
                self.tvResults.removeAll()
                if let s = shows{
                    if s.count == 0{
                        DispatchQueue.main.async {
                            self.noResultsLabel.alpha = 1
                            self.tvResults = s
                            self.movieResultsCollection.reloadData()
                            self.loadingView.alpha = 0
                            self.activityIcon.stopAnimating()
                        }
                        return
                    }
                    //truncate here
                    self.tvResults = s
                    let remainder:Int = (s.count % 3)
                    if remainder != 0 && s.count > 18{
                        for _ in 0...(remainder - 1) {
                            if let tv = self.tvResults.popLast(){
                                self.tempTv.append(tv)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.noResultsLabel.alpha = 0
                        self.movieResultsCollection.reloadData()
                        self.loadingView.alpha = 0
                        self.activityIcon.stopAnimating()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.noResultsLabel.alpha = 1
                        self.loadingView.alpha = 0
                        self.activityIcon.stopAnimating()
                    }
                }
            }
            self.lastSearchedTv = searchBar.text ?? ""
        default:
            break
        }
        self.searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count <= 0{
            switch self.segmentedView.selectedSegmentIndex{
            case 0:
                self.movieResults.removeAll()
                self.lastSearchedMovies = ""
            case 1:
                self.tvResults.removeAll()
                self.lastSearchedTv = ""
            default:
                break;
            }
           
            self.movieResultsCollection.reloadData()
            self.noResultsLabel.alpha = 1
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentedView.selectedSegmentIndex {
        case 0:
            return self.movieResults.count
        case 1:
            return self.tvResults.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        cell.posterImage.image = #imageLiteral(resourceName: "Image Place Holder")
        switch segmentedView.selectedSegmentIndex {
        case 0:
            let movie = movieResults[indexPath.row]
            cell.movieTitle.text = movie.title
            if let movieUrl = movie.posterPath{
                cell.posterImage.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w154\(movieUrl)")
            }
            return cell
        case 1:
            let show = tvResults[indexPath.row]
            cell.movieTitle.text = show.name
            if let movieUrl = show.posterPath{
                cell.posterImage.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w154\(movieUrl)")
            }
            return cell
        default:
            return cell
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            switch segmentedView.selectedSegmentIndex{
            case 0:
                if movieResults.count == 0{
                    return
                }
                if !fetchingMoreMovies{
                    getMoreMovies()
                }
            case 1:
                if tvResults.count == 0{
                    return
                }
                if !fetchingMoreTv{
                    getMoreMovies()
                }
            default:
                return
            }
        }
    }
    
    var fetchingMoreMovies = false
    var fetchingMoreTv = false
    var moviePagesFetched = 1
    var tvPagesFetched = 1
    
    func getMoreMovies(){
        self.loadingView.alpha = 1
        self.activityIcon.startAnimating()
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            fetchingMoreMovies = true
            self.moviePagesFetched += 1
            movieHelper.searchMovies(query: lastSearchedMovies, page: moviePagesFetched) { (movies) in
                if movies.count == 0{
                    if self.tempMovie.count != 0{
                        for _ in 0...(self.tempMovie.count - 1){
                            if let mov = self.tempMovie.popLast(){
                                self.movieResults.append(mov)
                            }
                        }
                        DispatchQueue.main.async {
                            self.loadingView.alpha = 0
                            self.activityIcon.stopAnimating()
                            self.movieResultsCollection.reloadData()
                        }
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.loadingView.alpha = 0
                        self.activityIcon.stopAnimating()
                    })
                    return
                }
                if self.tempMovie.count != 0{
                    for _ in 0...(self.tempMovie.count - 1){
                        if let mov = self.tempMovie.popLast(){
                            self.movieResults.append(mov)
                        }
                    }
                }
                self.movieResults.append(contentsOf: movies)
                let remainder:Int = (self.movieResults.count % 3)
                if remainder != 0{
                    for _ in 0...(remainder - 1) {
                        if let mov = self.movieResults.popLast(){
                            self.tempMovie.append(mov)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.movieResultsCollection.reloadData()
                    self.fetchingMoreMovies = false
                    self.loadingView.alpha = 0
                    self.activityIcon.stopAnimating()
                }
            }
        case 1:
            fetchingMoreTv = true
            self.tvPagesFetched += 1
            tvHelper.searchTVShows(query: lastSearchedTv, page: tvPagesFetched) { (shows) in
                if shows == nil || shows!.count == 0{
                    if self.tempTv.count != 0{
                        for _ in 0...(self.tempTv.count - 1){
                            if let tv = self.tempTv.popLast(){
                                self.tvResults.append(tv)
                            }
                        }
                        DispatchQueue.main.async {
                            self.loadingView.alpha = 0
                            self.activityIcon.stopAnimating()
                            self.movieResultsCollection.reloadData()
                        }
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.loadingView.alpha = 0
                        self.activityIcon.stopAnimating()
                    })
                    return
                }
                if self.tempTv.count != 0{
                    for _ in 0...(self.tempTv.count - 1){
                        if let tv = self.tempTv.popLast(){
                            self.tvResults.append(tv)
                        }
                    }
                }
                self.tvResults.append(contentsOf: shows!)
                let remainder:Int = (self.tvResults.count % 3)
                if remainder != 0{
                    for _ in 0...(remainder - 1){
                        if let tv = self.tvResults.popLast(){
                            self.tempTv.append(tv)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.movieResultsCollection.reloadData()
                    self.fetchingMoreTv = false
                    self.loadingView.alpha = 0
                    self.activityIcon.stopAnimating()
                }
            }

        default:
            break
        }
    }
    
    var movieToSend: Movie!
    var imageToSend: UIImage!
    var tvToSend: Tv!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        imageToSend = cell.posterImage.image
        switch self.segmentedView.selectedSegmentIndex{
        case 0:
            movieToSend = self.movieResults[indexPath.row]
            performSegue(withIdentifier: "SearchToMovie", sender: self)
        case 1:
            tvToSend = self.tvResults[indexPath.row]
            performSegue(withIdentifier: "SearchToTV", sender: self)
        default:
            break
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToMovie"
        {
            if let dest = segue.destination as? MovieViewController
            {
                dest.movie = movieToSend
                dest.posterUIImage = imageToSend
            }
        }
        else if segue.identifier == "SearchToTV"
        {
            if let dest = segue.destination as? TVViewController
            {
                dest.tv = tvToSend
                dest.posterUIImage = imageToSend
            }
        }
    }
    
}
