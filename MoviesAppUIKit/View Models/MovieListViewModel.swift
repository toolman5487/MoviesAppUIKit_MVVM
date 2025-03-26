//
//  MovieListViewModel.swift
//  MoviesAppUIKit
//
//  Created by Willy Hsu on 2025/3/26.
//

import Foundation
import Combine

class MovieListViewModel{
    
    @Published private(set) var movies: [Movie] = []
    private let httpClient: HTTPClient
    private var cancellables:Set<AnyCancellable> = []
    private var searchSubject = CurrentValueSubject<String, Never>("")
    @Published var loadingCompleted:Bool = false
    init(httpClient:HTTPClient){
        self.httpClient = httpClient
        setupSearchPublisher()
    }
    
    func setupSearchPublisher() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
            self?.loadMovies(search: searchText)
        }.store(in: &cancellables)
    }
    
    func setSearchText(_ searchText: String){
        searchSubject.send(searchText)
    }
    
    func loadMovies(search:String){
        httpClient.fetchMovie(search)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("ok")
                    self?.loadingCompleted = true
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.movies = movies
            }
            .store(in: &cancellables)
    }
}
