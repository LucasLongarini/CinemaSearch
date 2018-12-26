//
//  TvHelper.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-09.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
enum TvType {
    case popular
    case airingToday
    case onAir
    case topRated
}
class TvHelper {
    
    let tmdbApiKey = "5ef3636bee9e119d63d5c4c91aefc53d"
    
    func downloadTv(type: TvType,page: Int, completion: @escaping ([Tv])->()){
        var urlString: String!
        
        switch type {
        case .popular:
            urlString = "https://api.themoviedb.org/3/tv/popular?api_key=\(tmdbApiKey)&language=en-US&page=\(page)"
        case .airingToday:
            urlString = "https://api.themoviedb.org/3/tv/airing_today?api_key=\(tmdbApiKey)&language=en-US&page=\(page)"
        case .onAir:
            urlString = "https://api.themoviedb.org/3/tv/on_the_air?api_key=\(tmdbApiKey)&language=en-US&page=\(page)"
        case .topRated:
            urlString = "https://api.themoviedb.org/3/tv/popular?api_key=\(tmdbApiKey)&language=en-US&page=\(page)"
        }
        
        let url = URL(string: urlString!)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else {return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(JsonTvData.self, from: data)
                completion(jsonData.results!)
            }catch let jsonErr{
                var err: String!
                switch type{
                case .popular:
                    err = "popular"
                case .airingToday:
                    err = "air today"
                case .onAir:
                    err = "on air"
                case .topRated:
                    err = "topRated"
                }
                print("Failed to decode: In downloadTV in \(err!)", jsonErr)
            }
           
        }.resume()
        
    }
    
    struct JsonTvData: Decodable {
        var page: Int = 0
        var results: [Tv]? = [Tv]()
    }
    
    func downloadTvDetails(tvID: Int, completion: @escaping (OtherTvData)->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(OtherTvData.self, from: data)
                completion(jsonData)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getRecommenedTv(tvID: Int, completion: @escaping ([Tv])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/recommendations?api_key=\(tmdbApiKey)&language=en-US&page=1"
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
                let jsonData = try decoder.decode(JsonTvData.self, from: data)
                completion(jsonData.results!)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getEpisodes(tvID:Int, seasonNumber: Int, completion: @escaping ([Episode]?)->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/season/\(seasonNumber)?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(JsonEpisodeData.self, from: data)
                completion(jsonData.episodes)
                
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
    }
        
    struct JsonEpisodeData: Decodable{
        var episodes: [Episode]?
    }
    
    func searchTVShows(query: String, page: Int, completion: @escaping ([Tv]?)->()){
        let queryString = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.themoviedb.org/3/search/tv?api_key=\(tmdbApiKey)&language=en-US&query=\(queryString)&page=\(page)"
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
                let jsonData = try decoder.decode(JsonTvData.self, from: data)
                completion(jsonData.results)
                
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
    }

    func getTVTrailerIDs(tvID:Int, completion: @escaping ([VideoData])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/videos?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(JsonVideoData.self, from: data)
                completion(jsonData.results)
                
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getSeasonTrailerIDs(tvID:Int, seasonNumber: Int, completion: @escaping ([VideoData])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/season/\(seasonNumber)/videos?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(JsonVideoData.self, from: data)
                completion(jsonData.results)
                
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getEpisodeTrailerIDs(tvID:Int, seasonNumber: Int, episodeNumber:Int, completion: @escaping ([VideoData])->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)/season/\(seasonNumber)/episode/\(episodeNumber)/videos?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(JsonVideoData.self, from: data)
                completion(jsonData.results)
                
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
            }.resume()
        
    }
    
    func getAllTvDetails(tvID: Int, completion: @escaping (AllTvInfo)->()){
        let urlString = "https://api.themoviedb.org/3/tv/\(tvID)?api_key=\(tmdbApiKey)&language=en-US"
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
                let jsonData = try decoder.decode(AllTvInfo.self, from: data)
                completion(jsonData)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
            
        }.resume()
    }
}
