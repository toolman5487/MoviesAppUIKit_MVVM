//
//  Movie.swift
//  MoviesAppUIKit
//
//  Created by Willy Hsu on 2025/3/25.
//

import Foundation

struct MoviewResponse:Codable{
    let Search: [Movie]
}

struct Movie:Codable{
    let title:String
    let year:String
    let poster:String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case poster = "Poster"
    }
}

