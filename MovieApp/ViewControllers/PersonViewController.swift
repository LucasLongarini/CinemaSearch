//
//  PersonViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-14.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TabbedCellDelegate{
    
    //Synchronization for loading differnt data asynchronously
    let semaphore = DispatchSemaphore(value: 1)
    var totalDownloaded:Int = 0
    
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var tabbedCollection: UICollectionView!
    
    var person: Person?
    var personImage:UIImage?
    var personHelper = PersonHelper()
    
    //for table view's
    var allPersonInfo: AllPersonInfo?
    var personCredits: PersonCredits?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabbedCollection.alpha = 0

        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        setupView()
        downloadPerson()
        downloadPersonCredits()
    }
    
    func downloadPersonCredits(){
        guard let person = self.person else{return}
        personHelper.getPersonCredits(personID: person.id) { (results) in
            self.personCredits = results
            DispatchQueue.main.async {
                self.tabbedCollection.reloadData()
            }
            self.checkDownload()
        }
    }
    
    func downloadPerson(){
        guard let person = self.person else{return}
        personHelper.getPerson(personID: person.id) { (personInfo) in
            self.allPersonInfo = personInfo
            DispatchQueue.main.async {
                self.tabbedCollection.reloadData()
            }
            self.checkDownload()
        }
    }
    
    func setupView(){
        tabbedCollection.delegate = self
        tabbedCollection.dataSource = self
        loadingView.layer.cornerRadius = 10
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.tabbedCollection.frame.width, height: self.tabbedCollection.frame.height)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        tabbedCollection.collectionViewLayout = layout
        tabbedCollection.isPagingEnabled = true
        
        self.navigationItem.title = person?.name ?? ""
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabbedCell", for: indexPath) as! TabbedCell
        cell.setImage(image: self.personImage)
        if indexPath.row == 0{
            cell.cellIndex = 0
            cell.allPersonInfo = self.allPersonInfo
            cell.delegate = self
            cell.tableView.reloadData()
        }else{
            if self.personCredits?.movies?.count ?? 0 == 0{
                cell.noResultsLabel.alpha = 1
            }
            cell.cellIndex = 1
            cell.personCredits = self.personCredits
            cell.delegate = self
            cell.setSegmentControl()
            cell.tableView.reloadData()
        }

        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        if !dontScroll && offset>0 && offset <= self.view.frame.width{
            self.segmentedView.selector.frame.origin.x = (scrollView.contentOffset.x / 2)
        
            //left
            if offset < self.view.frame.width / CGFloat(2){
                self.segmentedView.switchIndex(index: 0)
            }
                //right
            else{
                self.segmentedView.switchIndex(index: 1)
            }
        }
    }
    
    
    var dontScroll:Bool = false
    @IBAction func segmentedChanged(_ sender: TabbedSegmentedControl) {
        dontScroll = true
        switch sender.selectedSegmentIndex {
        case 0:
            tabbedCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        case 1:
            tabbedCollection.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: true)
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3/10) {
            self.dontScroll = false
        }
    }
    
    var movieToSend:Movie?
    var tvToSend:Tv?
    var imageToSend:UIImage?
    
    func movieTapped(movie: Movie, image: UIImage) {
        self.movieToSend = movie
        self.imageToSend = image
        performSegue(withIdentifier: "PersonToMovie", sender: self)
    }
    
    func tvTapped(tv: Tv, image: UIImage) {
        self.tvToSend = tv
        self.imageToSend = image
        performSegue(withIdentifier: "PersonToTv", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PersonToMovie"{
            if let dest = segue.destination as? MovieViewController{
                if let movie = self.movieToSend, let image = self.imageToSend{
                    dest.movie = movie
                    dest.posterUIImage = image
                }
            }
        }
        else if segue.identifier == "PersonToTv"{
            if let dest = segue.destination as? TVViewController{
                if let tv = self.tvToSend, let image = self.imageToSend{
                    dest.tv = tv
                    dest.posterUIImage = image
                }
            }
        }
    }
    
    
    func doAnimation(){
        self.loadingView.alpha = 0
        self.activityIcon.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.tabbedCollection.alpha = 1
        }
    }
    
    func checkDownload(){
        self.semaphore.wait()
        self.totalDownloaded += 1
        if self.totalDownloaded == 2{
            self.semaphore.signal()
            DispatchQueue.main.async {
                self.doAnimation()
            }
        }else{self.semaphore.signal()}
    }

    
}
