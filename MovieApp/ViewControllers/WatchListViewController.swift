//
//  WatchListViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-27.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class WatchListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultsLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext!
    var movieList: [MovieWatch]!
    var tvList: [TvWatch]!

    @IBOutlet weak var segmentedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsLabel.alpha = 0
        self.tableView.tableFooterView = UIView()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: segmentedView.frame.height, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        self.tableView.reloadData()
    }
    
    func fetchData(){
        let presentRequest:NSFetchRequest<MovieWatch> = MovieWatch.fetchRequest()
        
        do{
            movieList = try managedObjectContext.fetch(presentRequest)
            if self.segmentedView.selectedSegmentIndex == 0{
                if self.movieList.count <= 0{resultsLabel.alpha = 1}
                else{resultsLabel.alpha = 0}
            }

        }
        catch{print("Could not load data from database: \(error.localizedDescription)")}
        
        let presentRequest2:NSFetchRequest<TvWatch> = TvWatch.fetchRequest()
        do{
            tvList = try managedObjectContext.fetch(presentRequest2)
            if self.segmentedView.selectedSegmentIndex == 1{
                if self.tvList.count <= 0{resultsLabel.alpha = 1}
                else{resultsLabel.alpha = 0}
            }
        }
        catch{print("Could not load data from database: \(error.localizedDescription)")}
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + segmentedView.frame.height) < 0{
            segmentedTopConstraint.constant = -(scrollView.contentOffset.y + segmentedView.frame.height) - 5
            self.view.layoutIfNeeded()
        }
        else{
            segmentedTopConstraint.constant = -5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            if let l = movieList{
                return l.count
            }else{return 0}
        case 1:
            if let t = tvList{
                return t.count
            }else{return 0}
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchlistCell", for: indexPath) as! WatchListCell
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            if let list = self.movieList{
                let l = list[indexPath.row]
                cell.backgroundImage.image = UIImage(data: l.image!)
                cell.movieTitleLabel.text = l.name
            }
        case 1:
            if let list = self.tvList{
                let t = list[indexPath.row]
                cell.backgroundImage.image = UIImage(data: t.image!)
                cell.movieTitleLabel.text = t.name
            }
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            switch self.segmentedView.selectedSegmentIndex{
            case 0:
                let movieID = Int(self.movieList[indexPath.row].id)
                self.movieList.remove(at: indexPath.row)
                if self.movieList.count <= 0{resultsLabel.alpha = 1}
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                removeMovieFromWatchlist(movieID: movieID)
            case 1:
                let tvID = Int(self.tvList[indexPath.row].id)
                self.tvList.remove(at: indexPath.row)
                if self.tvList.count <= 0{resultsLabel.alpha = 1}
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                removeTVFromWatchlist(tvID: tvID)
            default:
                break
            }
        }
    }
    func removeTVFromWatchlist(tvID:Int){
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
    func removeMovieFromWatchlist(movieID:Int){
        let deleteRequest:NSFetchRequest<MovieWatch> = MovieWatch.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "id==\(movieID)")
        do {
            let objects = try managedObjectContext.fetch(deleteRequest)
            print(objects.count)
            for object in objects {
                managedObjectContext.delete(object)
            }
            try managedObjectContext.save()
        } catch{
            print("Error deleting core data object with id \(movieID) : \(error.localizedDescription)")
        }
    }
    
    var IDToSend: Int!
    var imageToSend: UIImage!
    var titleToSend: String?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            self.IDToSend = Int(self.movieList[indexPath.row].id)
            self.titleToSend = self.movieList[indexPath.row].name
            let cell = tableView.cellForRow(at: indexPath) as! WatchListCell
            imageToSend = cell.backgroundImage.image
            performSegue(withIdentifier: "WatchlistToMovie", sender: self)
        case 1:
            self.IDToSend = Int(self.tvList[indexPath.row].id)
            self.titleToSend = self.tvList[indexPath.row].name
            let cell = tableView.cellForRow(at: indexPath) as! WatchListCell
            imageToSend = cell.backgroundImage.image
            performSegue(withIdentifier: "WatchlistToTv", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WatchlistToMovie"{
            if let dest = segue.destination as? MovieViewController{
                dest.watchlistMovieID = IDToSend
                dest.watchlistMovieBackgroundImage = imageToSend
                dest.watchlistTitle = self.titleToSend
            }
        }
        if segue.identifier == "WatchlistToTv"{
            if let dest = segue.destination as? TVViewController{
                dest.watchListTvID = IDToSend
                dest.watchListBackgroundImage = imageToSend
                dest.watchlistTitle = self.titleToSend
            }
        }
    }
    
    @IBAction func segmentedViewChanged(_ sender: Any) {
        self.tableView.reloadData()
        self.tableView.alpha = 0
        switch self.segmentedView.selectedSegmentIndex {
        case 0:
            if self.movieList.count <= 0{
                resultsLabel.alpha = 1
            }else{resultsLabel.alpha = 0}
        case 1:
            if self.tvList.count <= 0{
                resultsLabel.alpha = 1
            }else{resultsLabel.alpha = 0}
        default:
            break;
        }
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
        }
    }
    
}
