//
//  Movies.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import Foundation

struct Movie: Codable {
    let posterPath: String
    let adult: Bool
    let overview: String
    let releaseDate: String
    let id: Int
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPath: String
    let popularity: Double
    let voteCount: Int
    let video: Bool
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        
        case poster_path
        case adult
        case overview
        case release_date
        case id
        case original_title
        case original_language
        case title
        case backdrop_path
        case popularity
        case vote_count
        case video
        case vote_average

    }
    
}


extension Movie {
    init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        posterPath = try container.decode(String.self, forKey: .poster_path)
        adult = try container.decode(Bool.self, forKey: .adult)
        overview = try container.decode(String.self, forKey: .overview)
        releaseDate = try container.decode(String.self, forKey: .release_date)
        id = try container.decode(Int.self, forKey: .id)
        originalTitle = try container.decode(String.self, forKey: .original_title)
        originalLanguage = try container.decode(String.self, forKey: .original_language)
        title = try container.decode(String.self, forKey: .title)
        backdropPath = try container.decode(String.self, forKey: .backdrop_path)
        popularity = try container.decode(Double.self, forKey: .popularity)
        voteCount = try container.decode(Int.self, forKey: .vote_count)
        video = try container.decode(Bool.self, forKey: .video)
        voteAverage = try container.decode(Double.self, forKey: .vote_average)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(posterPath, forKey: .poster_path)
        try container.encode(adult, forKey: .adult)
        try container.encode(overview, forKey: .overview)
        try container.encode(releaseDate, forKey: .release_date)
        try container.encode(id, forKey: .id)
        try container.encode(originalTitle, forKey: .original_title)
        try container.encode(originalLanguage, forKey: .original_language)
        try container.encode(title, forKey: .title)
        try container.encode(backdropPath, forKey: .backdrop_path)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(voteCount, forKey: .vote_count)
        try container.encode(video, forKey: .video)
        try container.encode(voteAverage, forKey: .vote_average)
    }
    
}


public struct Safe<Base: Decodable>: Decodable {
    public let value: Base?
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            print("ERROR: \(error)")
            // TODO: automatically send a report about a corrupted data
            self.value = nil
        }
    }
}
