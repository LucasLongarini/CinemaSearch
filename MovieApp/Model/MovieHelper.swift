//
//  MovieHelper.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-28.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

enum moviesType {
    case popular
    case new
    case comingSoon
    case topRated
}
class MovieHelper {
    let tmdbApiKey = "5ef3636bee9e119d63d5c4c91aefc53d"
    
    func downloadMovies(type: moviesType,page: Int, completion: @escaping ([Movie])->()){
        var urlString: String!
        let regionString = "&region=US"
//        if let region = Locale.current.regionCode{
//            regionString = "&region=\(region)"
//        }
        switch type {
        case .popular:
            urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(tmdbApiKey)&language=en-US&page=\(page)\(regionString)"
        case .new:
            urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(tmdbApiKey)&language=en-US&page=\(page)\(regionString)"
        case .comingSoon:
            urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(tmdbApiKey)&language=en-US&page=\(page)\(regionString)"
        case .topRated:
            urlString = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(tmdbApiKey)&language=en-US&page=\(page)\(regionString)"
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
                let jsonData = try decoder.decode(JsonMovieData.self, from: data)
                completion(jsonData.results)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
 
    }
    struct JsonMovieData: Decodable {
        var page: Int = 0
        var results: [Movie] = [Movie]()
    }
    
    func downloadMovieInfo(movieID: Int, completion: @escaping (OtherMovieDetails)->()){
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(tmdbApiKey)&language=en-US"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movieData = try decoder.decode(OtherMovieDetails.self, from: data)
                completion(movieData)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
    }
    
    func downloadWatchlistMovieInfo(movieID: Int, completion: @escaping (AllMoviInfo)->()){
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(tmdbApiKey)&language=en-US"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movieData = try decoder.decode(AllMoviInfo.self, from: data)
                completion(movieData)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
        
    }
    
    func downloadRecomendedMovies(movieID: Int, completion: @escaping ([Movie])->()){
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/recommendations?api_key=\(tmdbApiKey)&language=en-US&page=1"
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
                let jsonData = try decoder.decode(JsonMovieData.self, from: data)
                completion(jsonData.results)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
        
    }
    
    func searchMovies(query: String, page: Int,completion: @escaping ([Movie])->()){
        let queryString = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(tmdbApiKey)&language=en-US&query=\(queryString)&page=\(page)&include_adult=false"
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
                let jsonData = try decoder.decode(JsonMovieData.self, from: data)
                completion(jsonData.results)
            }catch let jsonErr{
                print("Failed to decode: ", jsonErr)
            }
        }.resume()
        
    }
    
    func getTrailerIDs(movieID:Int, completion: @escaping ([VideoData])->()){
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/videos?api_key=\(tmdbApiKey)&language=en-US"
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
    
    
}
