//
//  HTTPClient.swift
//  MoviesAppUIKit
//
//  Created by Willy Hsu on 2025/3/25.
//

import Foundation
import Combine

enum NetworkError: Error {
    case urlError
}

class HTTPClient {
    func fetchMovie(_ search:String) -> AnyPublisher <[Movie], Error>{
        guard let encodeSearch = search.urlEncoded,
              let url = URL(string: "https://www.omdbapi.com/?s=\(encodeSearch)&apikey=b2c1ea18")
        else{
            return Fail(error: NetworkError.urlError).eraseToAnyPublisher()
        }
        return  URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MoviewResponse.self, decoder: JSONDecoder())
            .map(\.Search)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie],Error> in
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
