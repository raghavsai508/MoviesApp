//
//  Constants.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 10/21/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: MovieDB
    struct MovieDB {
        static let APIScheme = "https"
        static let APIHost = "api.themoviedb.org"
        static let APIPath = "/3/movie/popular"
    }
    
    struct MovieDBImage {
        static let APIScheme = "https"
        static let APIHost = "image.tmdb.org"
        static let APIPath = "/t/p/"
    }
    
    struct MovieDBKeys {
        static let APIKey = "api_key"
        static let APILanguage = "language"
        static let APIPage = "page"
    }
    
    struct MovieDBValues {
        static let APIKey = ""
    }
    
    struct MovieSettings {
        static let Page = "page"
    }
    
    // MARK: PersistentStore
    struct PersistentStore {
        static let ModelName = "MoviesModel"
    }
    
}
