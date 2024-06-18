//
//  MoviesDataModel.swift
//  MoviesExplorer
//
//  Created by Gursimran Singh Gill on 2024-06-16.
//

import Foundation

struct MoviesData: Codable {
    let id: String
    let title: String
    let yearOfRelease: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case id = "imdbID"
        case title = "Title"
        case yearOfRelease = "Year"
        case poster = "Poster"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        yearOfRelease = try container.decode(String.self, forKey: .yearOfRelease)
        poster = try container.decode(String.self, forKey: .poster)
    }
}

struct Response: Decodable {
    let Search: [MoviesData]
    let totalResults: String
}
