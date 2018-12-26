//
//  PersonHelper.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-30.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class PersonHelper{
    let tmdbApiKey = "5ef3636bee9e119d63d5c4c91aefc53d"
    
    func getPeopleForMovie(movieId: Int, completion: @escaping ([Person])->()){
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(tmdbApiKey)"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonPeopleData.self, from: data)
                completion(jsonData.cast)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
    }
    
    func getPeopleForTv(tvId: Int, completion: @escaping ([Person])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvId)/credits?api_key=\(tmdbApiKey)"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonPeopleData.self, from: data)
                completion(jsonData.cast)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
    }
    
    func getPeopleForSeason(tvID: Int, seasonNumber: Int, completion: @escaping ([Person])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/season/\(seasonNumber)/credits?api_key=\(tmdbApiKey)&language=en-US"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonPeopleData.self, from: data)
                completion(jsonData.cast)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        
        }.resume()
    }
    
    func getPeopleForEpisode(tvID:Int, seasonNumber: Int, episodeNumber: Int, completion: @escaping ([Person]?)->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/season/\(seasonNumber)/episode/\(episodeNumber)/credits?api_key=\(tmdbApiKey)"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonAllPeopleData.self, from: data)
                var people:[Person]? = jsonData.cast
                if let guest = jsonData.guestStars{
                    people?.append(contentsOf: guest)
                }
                completion(people)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getPerson(personID:Int, completion: @escaping(AllPersonInfo)->()){
        let urlString = "https://api.themoviedb.org/3/person/\(personID)?api_key=\(tmdbApiKey)&language=en-US"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(AllPersonInfo.self, from: data)
                completion(jsonData)
            }catch let jsonErr{print("Failed to decode: ", jsonErr)}
        }.resume()
    }
    
    func getPersonCredits(personID:Int, completion: @escaping(PersonCredits)->()){
        let url = URL(string: "https://api.themoviedb.org/3/person/\(personID)/combined_credits?api_key=\(tmdbApiKey)&language=en-US")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else{return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonAllCreditsData.self, from: data)
                let allPeoplData = PersonCredits()
                for media in jsonData.cast{
                    guard let type = media.mediaType else{continue}
                    if type == "tv"{
                        let tv = Tv(id: media.id, name: media.name, overview: media.overview, firstAirDate: media.firstAirDate, voteAverage: media.voteAverage, backdropPath: media.backdropPath, posterPath: media.posterPath)
                        if (allPeoplData.tv!.filter({$0.id == tv.id})).count > 0 {continue}
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-mm-dd"
                        let bday = dateFormatter.date(from: tv.firstAirDate)
                        var timePassed:TimeInterval
                        if let b = bday{timePassed = b.timeIntervalSince1970}else{timePassed = 0}
                        var noneInserted:Bool = true
                        for(i,tvOther) in allPeoplData.tv!.enumerated(){
                            let otherTimePassed:TimeInterval = dateFormatter.date(from: tvOther.firstAirDate)?.timeIntervalSince1970 ?? 0
                            if timePassed > otherTimePassed{allPeoplData.tv!.insert(tv, at: i);noneInserted = false;break}
                        }
                        if noneInserted {allPeoplData.tv!.append(tv); noneInserted = true}
                    }
                    else if type == "movie"{
                        let movie = Movie(id: media.id, title: media.title, overview: media.overview, releaseDate: media.releaseDate, voteAverage: media.voteAverage, backdropPath: media.backdropPath, posterPath: media.posterPath)
                        if (allPeoplData.movies!.filter({$0.id == movie.id})).count > 0 {continue}
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-mm-dd"
                        let bday = dateFormatter.date(from: movie.releaseDate)
                        var timePassed:TimeInterval
                        if let b = bday{timePassed = b.timeIntervalSince1970}else{timePassed = 0}
                        var noneInserted:Bool = true
                        for (i,mov) in allPeoplData.movies!.enumerated(){
                            let otherTimePassed:TimeInterval = dateFormatter.date(from: mov.releaseDate)?.timeIntervalSince1970 ?? 0
                            if timePassed > otherTimePassed{allPeoplData.movies!.insert(movie, at: i);noneInserted = false;break}
                        }
                        if noneInserted {allPeoplData.movies!.append(movie); noneInserted = true}
                    }
                }
                completion(allPeoplData)
            }catch let jsonErr{print("Failed to decode: ", jsonErr)}
        }.resume()
    }
    
    struct JsonAllPeopleData: Decodable {
        var cast: [Person]?
        var guestStars: [Person]?
    }
    
    struct JsonPeopleData: Decodable {
        var id: Int = 0
        var cast: [Person] = [Person]()
    }
    
    struct JsonAllCreditsData:Decodable {
        var cast: [JsonAllCredits] = [JsonAllCredits]()
    }
    
    struct JsonAllCredits:Decodable{
        var id: Int = 0
        var title: String?
        var overview: String?
        var releaseDate: String?
        var voteAverage: Float?
        var backdropPath: String?
        var posterPath: String?
        var mediaType:String?
        var name: String?
        var firstAirDate: String?
    }
}

