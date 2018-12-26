//
//  DatabaseHelper.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-22.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DatabaseHelper{
    
    fileprivate static let db = Firestore.firestore()
    fileprivate static let userTitle = "Users"
    fileprivate static let reviewTitle = "Reviews"
    
    static func storeUser(user:User){
        var data:[String:Any] = [String:Any]()
        if let name = user.name.components(separatedBy: " ").first?.capitalized{
            data["name"] = name
        }else{data["name"] = user.name}
        if let profileURL = user.profileURL{data["profileURL"]=profileURL}
        else if let facebookID = user.facebookID{data["facebookID"] = facebookID}
        db.collection(userTitle).document(user.ID).setData(data)
    }
    
    fileprivate static func userToDictionary(user:User)->[String:Any]{
        var data:[String:Any] = [String:Any]()
        data["name"] = user.name
        data["ID"] = user.ID
        if let profileURL = user.profileURL{data["profileURL"]=profileURL}
        else if let facebookID = user.facebookID{data["facebookID"] = facebookID}
        return data
    }
    
    fileprivate static func dictionaryToUser(userDictionary:[String:Any])->User?{
        guard let name = userDictionary["name"] as? String else{return nil}
        guard let ID = userDictionary["ID"] as? String else{return nil}
        let facebookID = userDictionary["facebookID"] as? Int
        let profileURL = userDictionary["profileURL"] as? String
            
        return User(ID: ID, name: name, profileURL: profileURL, facebookID: facebookID)
  
    }
    
    static func getUser(uid:String, completion: @escaping(User?)->()){
        db.collection(userTitle).document(uid).getDocument { (document, error) in
            if error != nil{completion(nil);return}
            
            if let document = document, document.exists{
                let id = document.documentID
                let name = document.get("name") as? String ?? ""
                let profileURL:String? = document.get("profileURL") as? String ?? nil
                let facebookID:Int? = document.get("facebookID") as? Int ?? nil
                
                let user = User(ID: id, name: name, profileURL: profileURL, facebookID: facebookID)
                completion(user)
                
            }
            else{
                completion(nil)
            }
        }
    }
    
    static func postReview(review:Review, successful: @escaping (Bool)->()){
        var data:[String:Any] = [String:Any]()
        switch review.reviewType {
        case .Movie:
            data["movieID"] = review.mediaID
            increaseNumReviews(ID: review.mediaID, reviewType: .Movie)
        case .Tv:
            data["tvID"] = review.mediaID
            increaseNumReviews(ID: review.mediaID, reviewType: .Tv)
        case .Episode:
            data["episodeID"] = review.mediaID
            increaseNumReviews(ID: review.mediaID, reviewType: .Episode)
        }
        data["title"] = review.title
        data["description"] = review.description
        data["score"] = review.score
        data["time"] = Timestamp(date: review.time)
        data["reviewer"] = userToDictionary(user: review.reviewer)
        
        db.collection(reviewTitle).addDocument(data: data) { (error) in
            if let _ = error{
                successful(false)
            }
            else{
                successful(true)
            }
        }
    }
    
    fileprivate static func increaseNumReviews(ID:Int, reviewType:ReviewType){
        var collection:String
        switch reviewType {
        case .Movie:
            collection = "MovieNumber"
        case.Tv:
            collection = "TvNumber"
        case.Episode:
            collection = "EpisodeNumber"
        }
        let numReviewRef = db.collection(collection).document("\(ID)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let numReviewDocument: DocumentSnapshot
            do{
                try numReviewDocument = transaction.getDocument(numReviewRef)
            }catch let fetchError as NSError {
                numReviewRef.setData(["reviews" : 1])
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldReviews = numReviewDocument.data()?["reviews"] as? Int else{
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(numReviewDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            transaction.updateData(["reviews": oldReviews+1], forDocument: numReviewRef)
            
            return nil

        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    static func getReviews(query:Query, reviewType:ReviewType, mediaID:Int, completion: @escaping ([Review]?,Query?)->()){
//        var query:Query
//        switch reviewType {
//        case .Movie:
//            query = db.collection(reviewTitle).whereField("movieID", isEqualTo: mediaID).limit(to: 5).order(by: "time", descending: true)
//        case .Tv:
//            query = db.collection(reviewTitle).whereField("tvID", isEqualTo: mediaID).limit(to: 5).order(by: "time", descending: true)
//        case .Episode:
//            query = db.collection(reviewTitle).whereField("episodeID", isEqualTo: mediaID).limit(to: 5).order(by: "time", descending: true)
//        }
        query.getDocuments { (documents, error) in
            if error != nil{completion(nil, nil); return}
            if let documents = documents{
                var reviews = [Review]()
                for document in documents.documents{
                    
                    guard let description:String = document.get("description") as? String else{break}
                    guard let title:String = document.get("title") as? String else{break}
                    guard let score:Int = document.get("score") as? Int else{break}
                    guard let time:Timestamp = document.get("time") as? Timestamp else{break}
                    let date = time.dateValue()
                    
                    guard let reviewerDictionary = document.get("reviewer") as? [String:Any] else{break}
                    
                    guard let reviewer:User = dictionaryToUser(userDictionary: reviewerDictionary) else{break}
                    
                    let review = Review(reviewType: reviewType, mediaID: mediaID, description: description, title: title, score: score, time: date, reviewer: reviewer)
                    reviews.append(review)
                }
                guard let nextSnapshot = documents.documents.last else{return completion(reviews, nil)}
                //returns the next query to use
                completion(reviews, query.start(afterDocument: nextSnapshot))
            }
            else{
                completion(nil, nil)
            }
        }
        
    }
    
    static func getNumberOfReviews(for reviewType:ReviewType, mediaID:Int,completion: @escaping (Int)->()){
        var collectionName:String
        switch reviewType {
        case .Movie:
            collectionName = "MovieNumber"
        case .Tv:
            collectionName = "TvNumber"
        case.Episode:
            collectionName = "EpisodeNumber"
        }
        
        db.collection(collectionName).document("\(mediaID)").getDocument { (data, error) in
            if let error = error{
                print(error.localizedDescription)
                completion(0);return
            }
            if let data = data, data.exists{
                guard let numberOfReviews:Int = data.get("reviews") as? Int else{completion(0);return}
                completion(numberOfReviews)
            }
            else{
                completion(0)
            }
        }
    }
}
