//
//  ReviewViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-21.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FirebaseFirestore

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,ReviewCellDelegate, WriteReviewDelegate{
    
    var reviewType:ReviewType!
    var mediaTitle:String!
    var mediaID:Int!
    
    var reviews = [Review]()

    @IBOutlet weak var writeReviewButton: WriteButton!
    @IBOutlet weak var tableView: UITableView!
    
    var query:Query!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initially set the query
        query = Firestore.firestore().collection("Reviews").whereField("movieID", isEqualTo: mediaID).limit(to: 5).order(by: "time", descending: true)
        
        let backBTN = UIBarButtonItem(image: UIImage(named: "back icon"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        writeReviewButton.layer.cornerRadius = writeReviewButton.frame.width/2
        writeReviewButton.addCircleShadow()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 145
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        DatabaseHelper.getReviews(query: query, reviewType: reviewType, mediaID: mediaID) { (reviews, nextQuery)  in
            if let reviews = reviews{
                self.reviews = reviews
                if let nextQuery = nextQuery{
                    self.query = nextQuery
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            FBSDKLoginManager().logOut()
            UserSingleton.shared.isLoggedIn = false
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else{return UITableViewCell(style: .default, reuseIdentifier: " ")}
        
        let review = reviews[indexPath.row]
        cell.profilePicture.image = UIImage(named: "Person Placeholder Image")
        if review.reviewer.ID == UserSingleton.shared.user?.ID{
            cell.profilePicture.image = UserSingleton.shared.image
        }
        //load profile url first if there is one
        if let profileURL = review.reviewer.profileURL{
            cell.profilePicture.loadImageUsingCache(urlString: profileURL)
        }
        //else load the facebook profile image if there is one
        else if let facebookID = review.reviewer.facebookID{
            cell.profilePicture.loadImageUsingCache(urlString: "https://graph.facebook.com/\(facebookID)/picture?type=normal")
        }
        
        cell.delegate = self
        cell.nameLabel.text = review.reviewer.name
        cell.setReview(value: review.score)
        cell.headerLabel.text = review.title
        cell.dateLabel.text = review.time.toString()
        cell.setDesctiption(description: review.description)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showMorePressed() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewToWrite"{
            if let dest = segue.destination as? WriteReviewViewController{
                dest.reviewType = reviewType
                dest.mediaID = mediaID
                dest.mediaTitle = mediaTitle
                dest.delegate = self
            }
        }
    }
    
    @IBAction func writeReviewButtonPressed(_ sender: Any) {
        if UserSingleton.shared.isLoggedIn{
            performSegue(withIdentifier: "ReviewToWrite", sender: self)
        }
    }
    
    var fetchingMore = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if !fetchingMore{
                getMoreReviews()
            }
        }
    }
    
    func getMoreReviews(){
        fetchingMore = true
        DatabaseHelper.getReviews(query: self.query, reviewType: reviewType, mediaID: mediaID) { (moreReviews, nextQuery) in
            if let moreReviews = moreReviews{
                if moreReviews.count <= 0{return}
                self.reviews.append(contentsOf: moreReviews)
                if let nextQuery = nextQuery{
                    self.query = nextQuery
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.fetchingMore = false
                }
            }
        }
    }
    
    func reviewPosted(review: Review) {
        reviews.insert(review, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .top)
        tableView.endUpdates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
}
