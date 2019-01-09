//
//  NetworkManagerConvenience.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import Foundation
import UIKit

extension NetworkManager {
    
    func getMovies(page: Int, _ completionHandlerForMovies: @escaping(_ movies: [Movie]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        
        let parameters = [Constants.MovieDBKeys.APIKey: Constants.MovieDBValues.APIKey,
                          Constants.MovieDBKeys.APIPage: page] as [String: AnyObject]
        
        let url = urlFromParameters(parameters, withPathExtension: Constants.MovieDB.APIPath)
        print(url)
        
        let request = URLRequest(url: url)

        return taskForURLRequest(request, apiType: APIType.apiRequest, completionHandlerForRequest: { (dataObject, error) in
            if error != nil {
                completionHandlerForMovies(nil, error)
            } else {
                if let results = dataObject?["results"] as? [[String:AnyObject]] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: results, options: [])
                        let moviesSafeArray = try JSONDecoder().decode([Safe<Movie>].self, from: data)
                        let movies = moviesSafeArray.compactMap{ $0.value }
                        completionHandlerForMovies(movies, nil)
                    } catch {
                        print(error)
                    }
                } else {
                    var errorString = ""
                    if let errorValue = dataObject?["error"] as? String {
                        errorString = errorValue
                    }
                    
                    let userInfo = [NSLocalizedDescriptionKey : "Could not retreive movies : \(errorString)"]
                    completionHandlerForMovies(nil,NSError(domain: "getMoviesInformation", code: 0, userInfo: userInfo))

                }
            }
        })
    }
    
    func getPosterMovie(imageName: String, completionHandlerForMovieImage: @escaping(_ image: UIImage?, _ error: Error?) -> Void) -> URLSessionDataTask?  {

        let url = urlForMovieImage(withPathExtension: Constants.MovieDBImage.APIPath+"w185"+imageName)
        print(url)

        let request = URLRequest(url: url)

        return taskForURLRequest(request, apiType: APIType.apiImage, completionHandlerForRequest: { (dataObject, error) in
            if error != nil {
                completionHandlerForMovieImage(nil, error)
            } else {
                if let data = dataObject as? Data {
                    let image = UIImage(data: data)
                    completionHandlerForMovieImage(image, nil)
                } else {
                    completionHandlerForMovieImage(nil, error)
                }
            }
        })
        

    }
}
